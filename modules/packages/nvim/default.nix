{ pkgs, latestPkgs, config, lib, ... }:
{
  options = with lib.types; {
    pkgs.nvim.languages = {
      elixir = lib.mkOption {
        type = bool;
        default = false;
      };

      graphql = lib.mkOption {
        type = bool;
        default = false;
      };

      nix = lib.mkOption {
        type = bool;
        default = true;
      };

      python = lib.mkOption {
        type = bool;
        default = true;
      };

      rust = lib.mkOption {
        type = bool;
        default = true;
      };
    };
  };

  config = let
    opts = config.pkgs.nvim;
  in {
    home.packages = with pkgs; (
      [
        biome
      ]
      ++ (lib.optional opts.languages.nix nil)
      ++ (lib.optional opts.languages.graphql nodePackages.graphql-language-service-cli)
      ++ (lib.optionals opts.languages.python [ latestPkgs.ruff latestPkgs.ty ])
    );

    home.programs.neovim = {
      enable = true;
      extraConfig = ""
        + (builtins.readFile ./assets/init.nvim)
        + (lib.strings.join "\n" (
          []
          ++ (lib.optional opts.languages.python ''
            call extend(g:coc_global_extensions, [ '@yaegassy/coc-ruff', '@yaegassy/coc-ty' ])
          '')
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
            "formatOnSaveFiletypes" = [
              "javascript"
              "javascript.tsx"
              "javascriptreact"
              "typescript"
              "typescript.tsx"
              "typescriptreact"
              "python"
            ];
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
            });

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

          "editor.codeActionsOnSave" = {
            # the eslint's formatter takes lower priority than the tsserver's
            "source.fixAll.eslint" = "always";
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
