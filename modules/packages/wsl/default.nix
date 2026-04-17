{ pkgs, inputs, lib, config, ... }:
{
  imports = [
    inputs.wsl.nixosModules.default
  ];

  options = let
    inherit (lib) mkOption types;
    inherit (types) bool;
  in {
    pkgs.wsl = {
      nvidia.enable = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = lib.mkMerge [
    {
      wsl.enable = true;

      home.packages = with pkgs; [
        (callPackage ./win32yank.nix {})
      ];

      env.PATH = [ "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/" ];
    }

    (lib.mkIf config.pkgs.wsl.nvidia.enable {
      environment.systemPackages = with pkgs; [
        cudatoolkit
      ];

      environment.sessionVariables = {
        CUDA_PATH = "${pkgs.cudatoolkit}";
        LD_LIBRARY_PATH = [ "/usr/lib/wsl/lib" ];
      };

      hardware.nvidia.open = true;
      services.xserver.videoDrivers = ["nvidia"];
      wsl.useWindowsDriver = true;
    })
  ];
}
