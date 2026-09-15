{ writeShellApplication, age, sops, jq, yq-go, git, coreutils, gnugrep, gawk }:
writeShellApplication {
  name = "create-secret";
  runtimeInputs = [ age sops jq yq-go git coreutils gnugrep gawk ];
  text = ''
    usage() {
      echo "Usage: create-secret [--user USER] [--force | --add-key] [--age-recipient KEY ...]"
      echo "Creation discovers local keys automatically; --age-recipient adds optional keys."
      echo "Use --add-key on a trusted device to grant another key access to existing secrets."
    }

    fail() {
      echo "$*" >&2
      exit 1
    }

    USER_OVERRIDE=""
    FORCE=0
    ADD_KEY=0
    RECIPIENTS=()
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --user|--age-recipient)
          [ "$#" -ge 2 ] && [ -n "$2" ] || fail "$1 requires a value"
          if [ "$1" = --user ]; then
            USER_OVERRIDE="$2"
          else
            RECIPIENTS+=("$2")
          fi
          shift
          ;;
        --force) FORCE=1 ;;
        --add-key) ADD_KEY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
      esac
      shift
    done
    [ "$FORCE" -eq 0 ] || [ "$ADD_KEY" -eq 0 ] || fail "--force and --add-key cannot be combined"

    U="''${USER_OVERRIDE:-$USER}"
    [[ "$U" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]*$ ]] || fail "Invalid user name"
    ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    cd "$ROOT"
    TEMPLATE="secrets/template.json"
    TARGET="secrets/$U.json"
    SOPS_CONFIG=".sops.yaml"
    CODEOWNERS="CODEOWNERS"
    [ -f "$SOPS_CONFIG" ] || fail "Missing $SOPS_CONFIG"
    if [ "$ADD_KEY" -eq 1 ]; then
      [ -f "$TARGET" ] || fail "Missing $TARGET. Run create-secret first."
    else
      [ -f "$TEMPLATE" ] || fail "Missing $TEMPLATE"
      if [ -e "$TARGET" ] && [ "$FORCE" -eq 0 ]; then
        fail "$TARGET already exists. Use --add-key to trust another key, or --force to recreate it."
      fi
    fi

    # Keep creation automatic. Adding trust explicitly asks for the other device's key.
    KEYS_FILE="''${SOPS_AGE_KEY_FILE:-''${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt}"
    if [ "$ADD_KEY" -eq 0 ] && [ -f "$KEYS_FILE" ]; then
      LOCAL_RECIPIENTS="$(age-keygen -y "$KEYS_FILE")"
      while IFS= read -r key; do
        [ -z "$key" ] || RECIPIENTS+=("$key")
      done <<< "$LOCAL_RECIPIENTS"
    fi
    while [ "''${#RECIPIENTS[@]}" -eq 0 ]; do
      read -r -p "Please enter the age public key to trust: " key || fail "No public key supplied"
      [ -z "$key" ] || RECIPIENTS+=("$key")
    done

    mkdir -p secrets
    WORK="$(mktemp -d "$ROOT/secrets/.create-secret.XXXXXX")"
    CONFIG_CHANGED=0
    TARGET_CHANGED=0
    HAD_TARGET=0
    [ ! -e "$TARGET" ] || HAD_TARGET=1
    cleanup() {
      local status=$?
      trap - EXIT
      if [ "$status" -ne 0 ]; then
        if [ "$CONFIG_CHANGED" -eq 1 ]; then cp -p "$WORK/config.original" "$SOPS_CONFIG"; fi
        if [ "$TARGET_CHANGED" -eq 1 ]; then
          if [ "$HAD_TARGET" -eq 1 ]; then cp -p "$WORK/target.original" "$TARGET"; else rm -f "$TARGET"; fi
        fi
      fi
      rm -rf "$WORK"
      exit "$status"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    cp -p "$SOPS_CONFIG" "$WORK/config.original"
    cp -p "$SOPS_CONFIG" "$WORK/config.yaml"
    if [ "$HAD_TARGET" -eq 1 ]; then cp -p "$TARGET" "$WORK/target.original"; fi
    mkdir "$WORK/secrets"

    for key in "''${RECIPIENTS[@]}"; do
      [[ "$key" == age1* ]] || fail "Expected an age public recipient"
      age -r "$key" </dev/null >/dev/null || fail "Invalid age recipient: $key"
    done
    printf '%s\n' "''${RECIPIENTS[@]}" | jq -Rsc 'split("\n") | map(select(length > 0)) | unique' > "$WORK/recipients.json"

    yq -o=json '.' "$SOPS_CONFIG" > "$WORK/config.json"
    MATCHES="$(jq -c --arg target "$TARGET" '
      (.creation_rules // []) | to_entries
      | map(select(.value.path_regex != null) | . as $rule | select($target | test($rule.value.path_regex)))
    ' "$WORK/config.json")"
    COUNT="$(jq 'length' <<< "$MATCHES")"
    [ "$COUNT" -le 1 ] || fail "Multiple SOPS rules match $TARGET; resolve the ambiguity first."
    if [ "$COUNT" -eq 0 ]; then
      [ "$ADD_KEY" -eq 0 ] || fail "No SOPS creation rule matches $TARGET"
      RULE_INDEX="$(jq '(.creation_rules // []) | length' "$WORK/config.json")"
      jq -n --arg user "$U" --slurpfile recipients "$WORK/recipients.json" '
        {path_regex: ("secrets(/|\\\\)" + ($user | gsub("\\."; "\\.")) + "\\.json$"),
         key_groups: [{age: $recipients[0]}]}
      ' > "$WORK/rule.json"
    else
      RULE_INDEX="$(jq '.[0].key' <<< "$MATCHES")"
      jq -e '.[0].value | (.key_groups | length) == 1 and (.key_groups[0] | keys) == ["age"] and (.key_groups[0].age | type) == "array"' <<< "$MATCHES" >/dev/null \
        || fail "Expected one age key group for $TARGET"
      jq '.[0].value' <<< "$MATCHES" > "$WORK/rule.json"
    fi

    # An outdated config must not revoke recipients already present in the file.
    if [ "$ADD_KEY" -eq 1 ]; then
      jq -e '.sops.age | type == "array" and length > 0' "$TARGET" >/dev/null \
        || fail "Expected an age-encrypted JSON secrets file"
      jq '[.sops.age[].recipient]' "$TARGET" > "$WORK/existing.json"
    else
      echo '[]' > "$WORK/existing.json"
    fi
    jq --slurpfile added "$WORK/recipients.json" --slurpfile existing "$WORK/existing.json" '
      .key_groups[0].age |= (. + $added[0] + $existing[0] | unique)
    ' "$WORK/rule.json" > "$WORK/merged.json"
    RULE_FILE="$WORK/merged.json" RULE_INDEX="$RULE_INDEX" \
      yq -i '.creation_rules[env(RULE_INDEX)] = (load(strenv(RULE_FILE)) | ... style="")' "$WORK/config.yaml"

    if [ "$ADD_KEY" -eq 1 ]; then
      cp -p "$TARGET" "$WORK/$TARGET"
      echo "Updating trusted keys for $TARGET..."
      (cd "$WORK"; sops --config config.yaml updatekeys --yes "$TARGET")
    else
      GIT_EMAIL="$(git config --get user.email || true)"
      [ -n "$GIT_EMAIL" ] || fail "No Git email configured. Please set 'git config user.email'."
      echo "Creating new secrets file..."
      (cd "$WORK"
        sops --config config.yaml encrypt --filename-override "$TARGET" --output "$TARGET" < "$ROOT/$TEMPLATE"
        # SOPS returns 200 when the editor leaves the template unchanged.
        sops --config config.yaml "$TARGET" || [ "$?" -eq 200 ]
      )
    fi

    CONFIG_CHANGED=1
    cp "$WORK/config.yaml" "$SOPS_CONFIG"
    TARGET_CHANGED=1
    cp "$WORK/$TARGET" "$TARGET"

    if [ "$ADD_KEY" -eq 0 ]; then
      touch "$CODEOWNERS"
      ENTRY="/secrets/$U.json $GIT_EMAIL"
      if ! grep -Fxq "$ENTRY" "$CODEOWNERS"; then
        awk -v path="/secrets/$U.json" '$1 != path' "$CODEOWNERS" > "$WORK/CODEOWNERS"
        printf '%s\n' "$ENTRY" >> "$WORK/CODEOWNERS"
        mv "$WORK/CODEOWNERS" "$CODEOWNERS"
      fi
      echo "CODEOWNER set to '$GIT_EMAIL'. Edit CODEOWNERS to use a different owner."
    fi
    if command -v direnv >/dev/null 2>&1; then
      direnv reload >/dev/null 2>&1 || true
    fi
    echo "OK: $TARGET"
  '';
}
