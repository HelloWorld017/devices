{ pkgs, latestPkgs, config, lib, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) bool;
  in {
    pkgs.nvim.languages = {
      elixir = mkOption {
        type = bool;
        default = false;
      };

      graphql = mkOption {
        type = bool;
        default = false;
      };

      nix = mkOption {
        type = bool;
        default = true;
      };

      python = mkOption {
        type = bool;
        default = true;
      };

      rust = mkOption {
        type = bool;
        default = true;
      };
    };
  };

  config = let
    opts = config.pkgs.nvim;
    jsFileTypes = [
      "javascript" "javascript.tsx" "javascriptreact"
      "typescript" "typescript.tsx" "typescriptreact"
    ];
  in {
    home.packages = (
      [
        latestPkgs.biome
        latestPkgs.oxfmt
        latestPkgs.oxlint
        latestPkgs.tree-sitter
      ]
      ++ (lib.optional opts.languages.nix latestPkgs.nil)
      ++ (lib.optional opts.languages.graphql latestPkgs.graphql-language-service-cli)
      ++ (lib.optionals opts.languages.python [ latestPkgs.ruff latestPkgs.ty ])
    );

    home.programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      extraConfig = ""
        + (builtins.readFile ./assets/init.nvim)
        + (lib.strings.join "\n" (
          []
          ++ (lib.optional opts.languages.elixir ''
            call extend(g:coc_global_extensions, [ 'coc-elixir' ])
          '')
          ++ (lib.optional opts.languages.rust ''
            call extend(g:coc_global_extensions, [ 'coc-rust-analyzer' ])
          '')
        ));
    };

    home.configFile = {
      "nvim/header.txt" = {
        source = ./assets/header.txt;
      };

      "nvim/coc-settings.json" = let
        json = pkgs.formats.json { };
      in {
        source = json.generate "coc-settings.json" ({
          # Generic
          "coc.preferences" = {
            "formatOnSaveFiletypes" = jsFileTypes ++ [ "python" ];
          };

          "workspace" = {
            "rootPatterns" = [
              ".git"
              ".hg"
              ".projections.json"
              "tsconfig.json"
            ];
          };

          # UI / Suggest
          "suggest" = {
            "noselect" = true;
            "enablePreselect" = false;
            "completionItemKindLabels" = {
              "text" = "  (text)";
              "method" = " (method)";
              "function" = " (function)";
              "constructor" = " (constructor)";
              "field" = " (field)";
              "variable" = " (variable)";
              "class" = " (class)";
              "interface" = " (interface)";
              "module" = " (module)";
              "property" = " (property)";
              "unit" = " (unit)";
              "value" = " (value)";
              "enum" = " (enum)";
              "enumMember" = " (enum member)";
              "keyword" = " (keyword)";
              "snippet" = " (snippet)";
              "color" = " (color)";
              "file" = " (file)";
              "reference" = " (reference)";
              "folder" = " (folder)";
              "constant" = " (constant)";
              "struct" = " (struct)";
              "event" = " (event)";
              "operator" = " (operator)";
              "typeParameter" = " (type parameter)";
              "default" = " (default)";
            };
            "floatConfig" = {
              "border" = true;
              "rounded" = true;
            };
          };

          # UI / Hover
          "hover" = {
            "floatConfig" = {
              "border" = true;
              "rounded" = true;
            };
          };

          # UI / Inlay
          "inlayHint" = {
            "enable" = true;
            "enableParameter" = true;
            "position" = "eol";
          };

          # LSP
          "languageserver" = {}
            // ({
              "oxlint" = {
                "command" = "oxlint";
                "args" = ["--lsp"];
                "filetypes" = jsFileTypes;
                "rootPatterns" = [".oxlintrc.json" "oxlint.config.ts" "oxlint.config.mts"];
                "requireRootPattern" = true;
              };

              "oxfmt" = {
                "command" = "oxfmt";
                "args" = ["--lsp"];
                "filetypes" = jsFileTypes;
                "rootPatterns" = [".oxfmtrc.json" "oxfmt.config.ts" "oxfmt.config.mts"];
                "requireRootPattern" = true;
              };
            })
            // (lib.optionalAttrs opts.languages.graphql {
              "graphql" = {
                "command" = "graphql-lsp";
                "args" = ["server" "-m" "stream"];
                "filetypes" = ["graphql"];
              };
            })
            // (lib.optionalAttrs opts.languages.nix {
              "nix" = {
                "command" = "nil";
                "filetypes" = ["nix"];
                "rootPatterns" = ["flake.nix"];
              };
            })
            // (lib.optionalAttrs opts.languages.python {
              "ruff" = {
                "command" = "ruff";
                "args" = ["server"];
                "filetypes" = ["python"];
                "rootPatterns" = ["pyproject.toml"];
                "requireRootPattern" = true;
              };
            })
            // (lib.optionalAttrs opts.languages.python {
              "ty" = {
                "command" = "ty";
                "args" = ["server"];
                "filetypes" = ["python"];
                "rootPatterns" = ["pyproject.toml"];
                "requireRootPattern" = true;
              };
            });

          "editor.codeActionsOnSave" = {
            "source.fixAll.eslint" = "always";
            "source.fixAll.oxlint" = "always";
            "source.fixAll.ruff" = "always";
            "source.organizeImports.ruff" = "always";
          };

          # Language-Specific
          "tsserver" = {
            "useLocalTsdk" = true;
          };

          "typescript" = {
            "inlayHints" = {
              "parameterNames.enabled" = "literals";
            };

            "format" = {
              "enable" = false;
            };
          };

          "javascript" = {
            "format" = {
              "enable" = false;
            };
          };

          "graphql" = {
            "filetypes" = ["graphql"];
          };

          "eslint" = {
            "format.enable" = true;
            "experimental.useFlatConfig" = true;
          };
        });
      };
    };

    home.file = {
      ".eslintrc" = {
        text = "{}";
      };
    };

    env.EDITOR = "nvim";
  };
}
