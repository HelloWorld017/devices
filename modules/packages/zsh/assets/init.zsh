# Set history
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
COMPLETION_WAITING_DOTS="true"
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
# setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# Fix home key
bindkey "^[[H"	beginning-of-line
bindkey "^[[F"	end-of-line
bindkey "^[[3~"	delete-char

# Start zinit
if [[ ! -f $HOME/.zinit/bin/zi.zsh ]]; then
	print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
	command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
	command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
		print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
		print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zi.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Prompts
zinit light HelloWorld017/agkozak-nenwflavoured

AGKOZAK_CUSTOM_RPROMPT='%(3V.%F{240}%3v %f.)'
AGKOZAK_CUSTOM_RPROMPT+=' %*'

zinit light agkozak/agkozak-zsh-prompt

# Plugins
# > Line Editing
zinit light jeffreytse/zsh-vi-mode

# > Autocompletion, Suggestions, Syntax Highlight
zinit wait lucid light-mode for \
	atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
		zdharma/fast-syntax-highlighting \
	blockf \
		zsh-users/zsh-completions \
	atload"!_zsh_autosuggest_start" \
		zsh-users/zsh-autosuggestions

# > History Search
zinit wait lucid light-mode for \
	zdharma/history-search-multi-word

# > Docker Compose (for Mac)
zinit lucid light-mode for \
	as"completion" is-snippet id-as"docker-completions/docker" \
		"https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker" \
	as"completion" is-snippet id-as"docker-completions/docker-compose" \
		"https://github.com/docker/compose/blob/master/contrib/completion/zsh/_docker-compose"

# Fuzzy Finder
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers color=always {}'"

# Fuzzy Git
export GF_SNAPSHOT_DIRECTORY="$HOME/.git-fuzzy-snapshots"
zinit ice as"program" pick"bin/git-fuzzy"
zinit light bigH/git-fuzzy

# The Fuck
eval $(thefuck --alias)
