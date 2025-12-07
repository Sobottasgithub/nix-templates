{
  description = "C++ template";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "1.2";
      packagesList = with pkgs; [ cmake gcc gnumake ];
    in {

      packages.${system} = {
        default = pkgs.stdenv.mkDerivation {
          pname = "cpp-template";
          inherit version;
          src = ./.;

          buildInputs = packagesList;

          configurePhase = ''
            cmake -B build -S $src -DCMAKE_BUILD_TYPE=Release
          '';

          buildPhase = ''
            cmake --build build
          '';

          installPhase = ''
            cmake --install build --prefix=$out
            cp LICENSE $out/
          '';
        };
      };

      devShells.${system}.default =
        let devPackages = packagesList ++ [ pkgs.bridge-utils ];
        in pkgs.mkShell {
          packages = devPackages;

          # bring build tools from our package
          inputsFrom = [ self.packages.${system}.default ];

          shellHook = ''
            git status
          '';
        };
    };
}
