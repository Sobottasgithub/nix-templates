{
  description = "Latex-template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "0.1.0";

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
      packages.${system} = {
        default = pkgs.stdenv.mkDerivation {
          pname = "latex-template";
          version = "0.1.0";
          src = ./.;

          buildInputs = [
            packages
          ];

          buildPhase = ''
            export HOME=$TMPDIR
            latexmk -pdf -shell-escape -pdflatex="pdflatex -interaction=nonstopmode" \
                    -jobname="main" \
                  -outdir=build main.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp ./build/main.pdf $out/
          '';
        };
      };

      devShells.default = pkgs.mkShell { buildInputs = packages; };
    };
}
