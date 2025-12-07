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

        javaFX = {
          path = ./javaFX;
          description = "JavaFX template";
          welcomeText = ''
            # Getting started
            - Run `nix run`
          '';
        };

        baisc = {
          path = ./basic;
          description = "flake utils with devshell";
          welcomeTest = ''
            # Enable direnv to enter devshell
            direnv allow
          '';
        };
      };

      # Optional: a default template
      templates.default = {
        path = ./empty;
        description = "Empty flake";
      };
    };
}
