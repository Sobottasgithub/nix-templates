{
  description = "Python template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "1.0";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          (pkgs.python3.withPackages (
            ps: with ps; [
              numpy
            ]
          ))
        ];

        shellHook = ''
          echo "Pythen environment done!"
          python --version
        '';
      };
    };
}
