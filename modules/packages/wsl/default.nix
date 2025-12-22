{ pkgs, inputs, lib, config, ... }:
{
	imports = [
		inputs.wsl.nixosModules.default
	];

	options = with lib.types; {
		pkgs.wsl = {
			nvidia.enable = lib.mkOption {
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
