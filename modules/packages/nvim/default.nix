{ config, lib, pkgs, ... }:

let
	cocSettings = {
		# Generic
		"coc.preferences" = {
			"formatOnSaveFiletypes" = [
				"javascript"
				"javascript.tsx"
				"javascriptreact"
				"typescript"
				"typescript.tsx"
				"typescriptreact"
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

		# LSP
		"languageserver" = {
			"graphql" = {
				"command" = "graphql-lsp";
				"args" = ["server" "-m" "stream"];
				"filetypes" = ["graphql"];
			};
			"nix" = {
				"command" = "nil";
				"filetypes" = ["nix"];
				"rootPatterns" = ["flake.nix"];
			};
		};

		# Language-Specific
		"tsserver" = {
			"useLocalTsdk" = true;
		};

		"typescript" = {
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

			# the eslint's formatter takes lower priority than the tsserver's
			"autoFixOnSave" = true;
		};
	};
in {
	config = {
		# TODO Make it additional languages configurable
		home.packages = with pkgs; [
			biome
			nil
			nodePackages.graphql-language-service-cli
		];
		home.programs.neovim = {
			enable = true;
			extraConfig = builtins.readFile ./assets/init.nvim;
		};

		home.configFile = {
			"nvim/header.txt" = {
				source = ./assets/header.txt;
			};

			"nvim/coc-settings.json" = let
				json = pkgs.formats.json { };
			in {
				source = json.generate "coc-settings.json" cocSettings;
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
