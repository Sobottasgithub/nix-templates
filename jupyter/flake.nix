{
  description = "Jupyter nix template"; # FIXME

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      projectName = "MyJupyterProject"; # FIXME
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
              ps:
              with ps;
              [
                jupyter
                jupyterlab
              ]
              ++ [
                # FIXME add additional packages
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
            inherit packages;
          };

          apps =
            let
              jupyterlab = {
                type = "app";
                program = "${pkgs.writeShellScript "run-jupyterlab" ''
                  exec ${pyPkgs}/bin/jupyter lab \
                    --ip=127.0.0.1 \
                    --port=8888 \
                    --no-browser \
                    --notebook_dir=./notebooks \
                ''}";
              };
            in
            {
              default = jupyterlab;
              inherit jupyterlab;
            };
        };
      flake = {
      };
    };
}
