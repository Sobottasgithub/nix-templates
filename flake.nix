{
  description = "A collection of flake templates";

  outputs =
    { self, ... }:
    {

      templates = {
        empty = {
          path = ./empty;
          description = "Empty flake";
        };

        java = {
          path = ./java;
          description = "Java template";
          welcomeText = ''
            # Getting started
            - Run `nix run`
          '';
        };

        basic = {
          path = ./basic;
          description = "flake utils with devshell";
          welcomeTest = ''
            # Enable direnv to enter devshell
            direnv allow
          '';
        };

        cpp = {
          path = ./cpp;
          description = "Cpp template";
          welcomeText = ''
            # Getting started
            - Run `nix run`
          '';
        };

        cpp-multi = {
          path = ./cpp-multi;
          description = "Cpp multi app template";
          welcomeText = ''
            # Welcome to your cpp multi application!
            - Run 'nix run .#A' or 'nix run .#B' to start your experience! 
          '';
        };

        latex = {
          path = ./latex;
          description = "Latex template";
          welcomeText = ''
            # Have fun with your fully working latex experience!
          '';
        };

        python = {
          path = ./python;
          description = "Python template";
          welcomeText = ''
            # Have fun with your fully working python experience! 
          '';
        };

        rust = {
          path = ./rust;
          description = "Rust template";
          welcomeText = ''
            # Have fun with your fully working python experience!
            try:

            nix run
          '';
        };

        php = {
          path = ./php;
          description = "PHP template with dev-server";
          welcomeText = ''
            # Getting started
            - Run `nix run` to launch the php development server
          '';
        };

        jupyter = {
          path = ./jupyter;
          description = "Jupyterlab flake";
          welcomeText = ''
            Run `nix run .#jupyterlab` to start a jupyterlab instance
          '';
        };

        pythonEnv = {
          path = ./pythonEnv;
          description = "Python Environment";
        };

        templates.default = {
          path = ./empty;
          description = "Empty flake";
        };
      };
    };
}
