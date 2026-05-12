{
  description = "Python3 environment nix template"; # FIXME

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      projectName = "MyPythonEnvProject"; # FIXME
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          pkgsPackages = with pkgs; [
            # FIXME: add packages from pkgs
          ];
          python = pkgs.python3;
          pyPkgs = (
            python.withPackages (
              ps: with ps; [
                # FIXME add python packages
              ]
            )
          );

          packages = [
            pyPkgs
          ]
          ++ pkgsPackages;
        in
        {
          # python environment
          devShells.default = pkgs.mkShellNoCC {
            name = "${projectName}-devshell";
            PYTHONPYCACHEPREFIX = ".pycache";
            inherit packages;
          };

        };
      flake = {
      };
    };
}
