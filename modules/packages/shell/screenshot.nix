{ pkgs, ... }:
{
	config = {
		home.configFile."hypr/scripts/screenrecord.sh" = {
			text = ''
				#!/usr/bin/env zsh

				mkdir -p ~/Screenshots
				if ! pkill -SIGINT wf-recorder; then
					FILE_PATH="$HOME/Screenshots/Screenrecord_$(date +%Y-%m-%d_%H-%M-%S).mp4";

					quickshell --path ${./assets/screenrecord.qml} &
					wf-recorder -g "$(slurp -b 000000a0 -c ffffff30 -w 1)" --file $FILE_PATH && \
						quickshell kill --path ${./assets/screenrecord.qml} && \
						ripdrag $FILE_PATH -s 64 -W 300 -H 96 -x
				fi
			'';
			executable = true;
		};

		home.configFile."hypr/scripts/screenshot.sh" = {
			text = ''
				#!/usr/bin/env zsh

				mkdir -p ~/Screenshots
				grim -g "$(slurp -b 000000a0 -c ffffff30 -w 1)" -t png - | \
					tee ~/Screenshots/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy && \
					swayosd-client --custom-message="Screenshot Taken" --custom-icon=camera-symbolic
			'';
			executable = true;
		};

		home.packages = with pkgs; [
			grim
			ripdrag
			slurp
			wf-recorder
			wl-clipboard
		];
	};
}
