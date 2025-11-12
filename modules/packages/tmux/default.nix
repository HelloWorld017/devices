{ ... }:

{
	config = {
		home.configFile."tmux/tmux-power.tmux" = {
			source = ./assets/tmux-power.tmux;
			executable = true;
		};

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

				# Config powerline
				set -g @tmux_power_theme 'custom'
				set -g @tmux_power_tc '#0084ff' # '#0066ff'
				set -g @tmux_power_user_icon ' '
				set -g @tmux_power_session_icon '  '
				set -g @tmux_power_time_icon '  '
				set -g @tmux_power_date_icon '  ' # '  '
				set -g @tmux_power_left_arrow_icon ''
				set -g @tmux_power_right_arrow_icon ''

				run-shell "~/.config/tmux/tmux-power.tmux"
			'';
		};
	};
}
