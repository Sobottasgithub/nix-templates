{
  description = "Assembly template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "1.2";
      packagesList = with pkgs; [
        gcc
        gnumake
      ];
    in
    {

      packages.${system} = {
        default = pkgs.stdenv.mkDerivation {
          pname = "assembly";
          inherit version;
          src = ./.;

          buildInputs = packagesList;

          dontConfigure = true;

          buildPhase = ''
            gcc -no-pie $src/src/main.s -o main
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp main $out/bin/assembly

            if [ -f LICENSE ]; then
              cp LICENSE $out/
            fi
          '';
        };
      };

      devShells.${system}.default =
        let
          devPackages = packagesList ++ [
           pkgs.bridge-utils

           pkgs.man-db
           pkgs.man-pages
           pkgs.man-pages-posix
           pkgs.stdman
         ];
        in
        pkgs.mkShell {
          packages = devPackages;

          # bring build tools from our package
          inputsFrom = [ self.packages.${system}.default ];

          extraOutputsToInstall = [ "man" "doc" ];

          shellHook = ''
            export MANPATH="${pkgs.man-pages}/share/man:${pkgs.man-pages-posix}/share/man:$MANPATH"
            git status
          '';
        };
    };
}
