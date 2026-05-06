{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      projectName = "MyPHPProject"; # FIXME: Name of the project
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
          lib,
          ...
        }:
        let

          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          php = (
            pkgs.php.buildEnv {
              extensions = (
                # all contains all the extensions
                { enabled, all }:
                enabled
                ++ (with all; [
                  xdebug
                  mysqli
                ])
              );
              extraConfig = ''
                xdebug.mode=debug
              '';
            }
          ); # php84

          phpPackages = with pkgs.php84Packages; [
            psalm
          ];

          pkgsPackages = with pkgs; [
            # FIXME: add pkgs packages here
            intelephense
            pretty-php
          ];
          packages = [
            php
            # FIXME: add packages you defined here
          ]
          ++ pkgsPackages
          ++ phpPackages;
        in
        {
          devShells.default = pkgs.mkShell {
            name = "${projectName}-devshell";

            inherit packages;
          };
          packages = {
            inherit php;
          };

          apps =
            let
              php-webserver = {
                type = "app";
                program = "${pkgs.writeShellScript "run-webserver" ''
                  exec ${lib.getExe php} -S \
                    localhost:8080 \
                    -t=./www-root \
                ''}";
              };
            in
            {
              default = php-webserver;
              inherit php-webserver;
            };
        };
      flake = {
      };
    };
}
