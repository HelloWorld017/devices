{ options, ... }:
{
	config = if (builtins.hasAttr "homebrew" options) then {
		# Initialize Homebrew Casks
		homebrew = {
			enable = true;
			brewPrefix = "/opt/homebrew/bin";
			onActivation = {
				autoUpdate = false;
				cleanup = "zap";
				upgrade = false;
			};

			global = {
				brewfile = true;
				lockfiles = true;
			};

			extraConfig = ''
				cask_args require_sha: true
			'';

			taps = [
				"homebrew/cask"
				"homebrew/core"
				"homebrew/services"
			];
		};

		env.HOMEBREW_NO_ALAYTICS = "1";
		env.PATH = [ "/opt/homebrew/bin" ];
	} else {};
}
