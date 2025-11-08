{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      empty = {
        source = ./empty;
        description = "Empty flake";
      };

      java = {
        source = ./java;
        description = "Java template";
        welcomeText = ''
          # Getting started
          - Run `nix run`
        '';
      };
    };

    defaultTemplate = self.templates.empty;
  };
}
