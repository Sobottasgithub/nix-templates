{
  description = "Cpp multi app setup";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "1.0";
      packagesList = with pkgs; [ cmake gcc gnumake ];
    in {
      packages.${system} = {
        client = pkgs.stdenv.mkDerivation {
          name = "A";
          pname = "A";

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

        server = pkgs.stdenv.mkDerivation {
          name = "B";
          pname = "B";

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

        default = pkgs.stdenv.mkDerivation {
          name = "default";
          pname = "default";

          inherit version;
          src = ./.;

          buildInputs = packagesList;

        };
      };

      devShells.${system}.default = let
        devPackages = packagesList ++ [ pkgs.bridge-utils pkgs.clang-tools ];
      in pkgs.mkShell {
        packages = devPackages;

        # bring build tools from our package
        inputsFrom = [ self.packages.${system}.default ];

        shellHook = ''
          git status
          cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        '';
      };
    };
}
