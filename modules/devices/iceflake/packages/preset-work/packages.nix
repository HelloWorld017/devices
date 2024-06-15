{ config, lib, pkgs, ... }:
{
	config = {
		homebrew.casks = [
			"asana"
			"notion"
			"slack"
			"tailscale"
		];

		home.packages = with pkgs; [
			_1password
			kind
		];

		home.programs.zsh = {
			shellAliases = {
				"fzclones" = "echo \"$HOME/workspace/ridi-clones/$(ls \"$HOME/workspace/ridi-clones\" | fzf)\"";
				"fzc" = "fzclones";
				"cdc" = "cd `fzclones`";
				"unsafe-chrome" = "open -n -a /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --args --user-data-dir=\"$HOME/workspace/drafts/unsafe-chrome-userdata\" --disable-web-security";
			};

			initExtra = ''
				clone_ridi () {
					cd ~/workspace/ridi-clones
					git clone ~/workspace/ridi-original $1

					cd $1
					git remote rename origin root
					git remote add origin ssh://git@github.com/ridi/ridi
					git checkout master
					git config --list | grep remote=root | cut -d'=' -f1 | xargs -n 1 git config --unset
				}
			'';
		};
	};
}
