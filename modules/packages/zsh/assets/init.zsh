# Set history
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
COMPLETION_WAITING_DOTS="true"
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# Fix home key
bindkey "^[[H"	beginning-of-line
bindkey "^[[F"	end-of-line
bindkey "^[[3~"	delete-char

# Start zinit
declare -A ZINIT
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
	print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
	command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
	command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
		print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
		print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
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
		zdharma-continuum/fast-syntax-highlighting \
	blockf \
		zsh-users/zsh-completions \
	atload"!_zsh_autosuggest_start" \
		zsh-users/zsh-autosuggestions

# > History Search
zinit wait lucid light-mode for \
	zdharma-continuum/history-search-multi-word

# Fuzzy Finder
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers color=always {}'"

# Fuzzy Git
export GF_SNAPSHOT_DIRECTORY="$HOME/.git-fuzzy-snapshots"
zinit ice as"program" pick"bin/git-fuzzy"
zinit light bigH/git-fuzzy

# The Fuck
eval $(thefuck --alias)

# Additional Local Non-Tracked Aliases
[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
