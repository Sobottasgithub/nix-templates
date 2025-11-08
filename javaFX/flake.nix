{
  description = "JavaFX template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      maven = pkgs.maven;
      jdk = pkgs.jdk23.override {
        enableJavaFX = true;
      };
    in
    {
      packages.${system} = {
        inherit jdk;
        default = maven.buildMavenPackage {
          pname = "JavaFXTemplate";
          version = "1.1.0";
          src = ./.;
          mvnHash = "sha256-my6yElw8xJN8w74ql7MzeGfu2X59md9620qSK5XJE6A=";
          mvnJdk = jdk;

          patches = [ ./patches/0001-update-PATCH-add-mainClass-using-maven-jar-plugin.patch ];

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            shopt -s nullglob
            set -euo pipefail

            mkdir -p $out/share/JavaFXTemplate

            jars=(./target/*.jar)
            if [ ''${#jars[@]} -eq 0 ]; then
              echo "No JAR file found? Maven install works?" >&2
              exit 1
            elif [ ''${#jars[@]} -gt 1 ]; then
              echo "Multiple JAR files found: ''${jars[*]}" >&2
              exit 1
            else
              JAR="''${jars[0]}"
            fi
            echo "Found JAR: ''$JAR"
            cp $JAR $out/share/JavaFXTemplate/
            JAR_NAME=$(basename $JAR)

            mkdir -p $out/bin
            echo "Wrapping $JAR_NAME"
            makeWrapper ${pkgs.lib.getExe jdk} $out/bin/javaFXTemplate --add-flags "-jar $out/share/JavaFXTemplate/$JAR_NAME"
          '';

          meta = {
            mainProgram = "javaFXTemplate";
          };
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          jdk
          pkgs.google-java-format
          pkgs.findutils
          pkgs.scenebuilder
          pkgs.xmlindent
          maven
        ];

        shellHook = '''';
      };
    };
}
