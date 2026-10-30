{
  description = "nenw's Flake";

  inputs = {
    # For restricted users:
    # > use self.submodules = false;
    self.submodules = true;

    # Core Inputs
    nixpkgs-base = { follows = "nixpkgs-20261028"; };
    nixpkgs-latest = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
    nixpkgs-20251020 = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
    nixpkgs-20261028 = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-base";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-base";
    };

    agenix = {
      url ="github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-base";
    };

    agenix-template = { url = "github:jhillyerd/agenix-template/1.0.0"; };
    std = { url = "github:chessai/nix-std"; };
    wsl = { url = "github:nix-community/NixOS-WSL/main"; };

    # Other Inputs
    figma-linux = {
      url = "github:HelloWorld017/figma-linux-nixos";
      inputs.nixpkgs.follows = "nixpkgs-base";
    };

    keeless = {
      url = "github:HelloWorld017/keeless/flakes";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };

    midnightway = {
      url = "github:HelloWorld017/midnightway/flakes-v1.2.0";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs-latest";
      inputs.nix-index-database.follows = "nix-index-database";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };

    notion-linux = {
      url = "github:HelloWorld017/notion-linux-nixos";
      inputs.nixpkgs.follows = "nixpkgs-base";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs-base";
    };
  };

  outputs = { ... }@inputs: {
    inherit (import ./modules/utils inputs) lib;
    inherit (import ./modules/devices inputs) nixosConfigurations darwinConfigurations;
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://github.com/HelloWorld017/keeless/releases/download/v0.1.5"
      "https://github.com/HelloWorld017/midnightway/releases/download/v1.2.0"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "keeless.nenw.dev-1:eKVDsvA/nRl6mi0y8of31nX8xyOKdtiWvMVh0y8HXqk="
      "midnightway.nenw.dev-1:gqHOdIZxjAMstAju9US/So4HFSwKiHuFoOHqgVZ1qS4="
    ];
  };
}
