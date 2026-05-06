{
  description = "Latex template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      projectName = "Latex-template";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
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
            (texlive.combine {
              inherit (texlive)
                scheme-medium
                geometry
                fancyhdr
                pgfplots
                latexmk
                ;
            })
          ];
          packages =
            with pkgs;
            [
              texlab
              zathura
              wmctrl
            ]
            ++ pkgsPackages;
        in
        {
          devShells.default = pkgs.mkShell { buildInputs = packages; };
        };
      flake = { };
    };
}
