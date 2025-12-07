{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      projectName = "BasicShell"; # FIXME: Name of the software / product bundled here
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
            # FIXME: add pkgs packages here
          ];
          packages = [
            # FIXME: add packages you defined here
          ]
          ++ pkgsPackages;
        in
        {
          devShells.default = pkgs.mkShell {
            name = "${projectName}-devshell";

            inherit packages;
          };
        };
      flake = {
      };
    };
}
