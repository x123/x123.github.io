{
  description = "x123.github.io pages devenv and hooks";
  inputs = {
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          alejandra.settings = {
            check = true;
          };
          deadnix.enable = true;
          deadnix.settings = {
            noLambdaArg = true;
            noLambdaPatternNames = true;
          };
          html-tidy.enable = true;
          markdownlint.enable = true;
          markdownlint.settings = {
            configuration = {
              "MD007" = {
                "indent" = 4;
                "start_indent" = 4;
              };
              "MD013" = {
                "tables" = false;
              };
              "MD025" = false;
              "MD029" = {
                "style" = "one_or_ordered";
              };
              "MD041" = false;
            };
          };
          statix.enable = true;
          typos = {
            enable = true;
            settings = {
              ignored-words = [
              ];
              locale = "en";
            };
          };
        };
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        # packages =
        #   [
        #     (nixpkgs.legacyPackages.${system}.python312.withPackages (python-pkgs: [
        #       python-pkgs.mkdocs-material
        #     ]))
        #   ]
        #   ++ [
        #     nixpkgs.legacyPackages.${system}.alejandra
        #     nixpkgs.legacyPackages.${system}.deadnix
        #     nixpkgs.legacyPackages.${system}.markdownlint-cli
        #     nixpkgs.legacyPackages.${system}.mdl
        #     nixpkgs.legacyPackages.${system}.statix
        #   ];
      };
    });
  };
}
