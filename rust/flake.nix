{
  description = "Rust template";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }@inputs:
    let
     system = "x86_64-linux";
     pkgs = import nixpkgs { inherit system; };

     version = "1.0";
     packageList = with pkgs; [ rustc cargo ];    
    in
    {
      packages.${system} = {
        default = pkgs.stdenv.mkDerivation {
          pname = "rust-template";
          inherit version;
          src = ./.;

          buildInputs = packageList;

          buildPhase = ''
            cargo build --release
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp target/release/rust-template $out/bin/
            cp LICENSE $out/
          '';
        };
      };

      
      devShells.${system}.default =
        let devPackages = packageList ++ [ pkgs.bridge-utils ];
        in pkgs.mkShell {
          packages = devPackages;

          # brin build tools from our package
          inputsFrom = [ self.packages.${system}.default ];

          shellHook = ''
            cargo --version
            git status
          '';
        };
    };
}
