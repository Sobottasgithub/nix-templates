{
  description = "java-template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, ... }: let
        jdk = pkgs.jdk21;
        buildInputs = [ jdk ];
        devTools = [ pkgs.google-java-format ];
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs ++ devTools;
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "java-template";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = buildInputs ++ [ pkgs.makeWrapper ];
          buildPhase = ''
            javac -Werror -g:none -deprecation -verbose Main.java
          '';
          installPhase = ''
            mkdir -p $out/{bin,lib}
            cp *.class $out/lib/
            makeWrapper ${pkgs.lib.getExe jdk} $out/bin/java-template \
              --add-flags "-cp $out/lib/ Main"
          '';
        };
      };

      templates.default = {
        description = "Java project template";
        source = ./.;
      };
    };
}
