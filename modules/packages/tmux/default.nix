{ config, lib, pkgs, ... }:

{
	config = {
		home.programs.tmux = {
			enable = true;
			escapeTime = 5;
			extraConfig = ''
				# Enable full colors
				set -g default-terminal 'screen-256color'
				set -ga terminal-overrides ',*256col*:Tc'

				# Open panes in same directory
				bind c new-window -c "#{pane_current_path}"
				bind '"' split-window -c "#{pane_current_path}"
				bind % split-window -h -c "#{pane_current_path}"

				# Vim-like Keybindings
				bind h select-pane -L
				bind j select-pane -D
				bind k select-pane -U
				bind l select-pane -R

				# Break / Join
				bind ! break-pane
				bind @ choose-window 'join-pane -h -t "%%"'
				bind C-@ choose-window 'join-pane -t "%%"'

				# Automatically re-number windows
				set -g renumber-windows on
			'';

			plugins = with pkgs.tmuxPlugins; [
				{
					plugin = power-theme;
					extraConfig = ''
						# Config powerline
						set -g @tmux_power_theme 'moon'
						set -g @tmux_power_user_icon ' ' # ' ﱤ '
						set -g @tmux_power_session_icon '  '
						set -g @tmux_power_time_icon '  '
						set -g @tmux_power_date_icon '  ' # '  '
						set -g @tmux_power_left_arrow_icon '​'
						set -g @tmux_power_right_arrow_icon '​'
					'';
				}
			];
		};
	};
}
