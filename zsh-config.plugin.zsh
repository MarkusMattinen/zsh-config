#!/bin/zsh

##################
## OS DETECTION ##
##################

OS=Unknown
DISTRO=Unknown

OSNAME="$(uname -s)"
case $OSNAME in
Linux)
  OS=Linux
  ;;
Darwin)
  OS=OSX
  DISTRO=OSX
  ;;
esac

if [ -f "/etc/issue" ]; then
  ISSUE="$(< /etc/issue)"
  case $ISSUE in
  Arch\ Linux*)
    DISTRO=ArchLinux
    ;;
  Rasbian* | Debian)
    DISTRO=Debian
    ;;
  Ubuntu*)
    DISTRO=Ubuntu
    ;;
  esac
fi

exit_error() {
  echo $@
  exit 1
}

has() {
  which $@ &>/dev/null
}

has_sudo() {
  sudo -nv 2>&1 | egrep ".*may not run sudo.*" &>/dev/null && return 1 || return 0
}


##################
## ZSH OPTIONS ###
##################

autoload -U colors && colors
autoload -U compinit && compinit
autoload -U promptinit && promptinit

zstyle ':completion:*' menu select

setopt nobeep
setopt kshglob

setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify

HISTFILE=~/.zshhistory
HISTSIZE=10000
SAVEHIST=10000

setopt complete_in_word
setopt NONOMATCH
autoload -U compinit && compinit
zstyle ':completion:*' glob 'yes'

##################
## KEY BINDINGS ##
##################

bindkey -e
bindkey "^[[1~" beginning-of-line       # Home
bindkey "^[[4~" end-of-line             # End
bindkey "^[[3~" delete-char             # Del
bindkey "^[[2~" overwrite-mode          # Insert
bindkey "^[[5~" history-search-backward # PgUp
bindkey "^[[6~" history-search-forward  # PgDn

##################
### VARIABLES ####
##################

export EDITOR="vim"
export GREP_COLOR="1;33"
export LESS="-R"
export LC_ALL="en_US.utf8"
export LC_TIME="en_GB.utf8"
export PAGER="less"

##################
#### ALIASES #####
##################

if which colordiff &> /dev/null; then
  alias diff='colordiff'
fi

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias ..="cd .."
alias ...="cd ../.."
alias nocomment='egrep -v "^\s*(#|$)"'
alias sudo='sudo '

if [ "$OS" = "Linux" ]; then
  alias chown='chown --preserve-root'
  alias chmod='chmod --preserve-root'
  alias chgrp='chgrp --preserve-root'
  alias rm="rm -I"
  alias ls='ls -hF --color=auto'
  alias l='ls -alF --color=auto'
elif [ "$OS" = "OSX" ]; then
  alias ls='ls -hF'
  alias l='ls -alF'
fi

if [ "$DISTRO" = "ArchLinux" ]; then
  alias cower='cower --color=auto'

  alias pac="sudo pacman"
  alias paci="sudo pacman -S"
  alias pacli="sudo pacman -U"
  alias pacu="sudo pacman -Syu"
  alias pacs="pacman -Ss"
  alias pacls="pacman -Qs"
  alias pacd="pacman -Si"
  alias pacld="pacman -Qi"
  alias pacr="sudo pacman -Rs"
  alias pacrr="sudo pacman -Rsn"
  alias paco="sudo pacman-optimize"
  alias pacexplicit="comm -23 <(pacman -Qeq | sort) <((pacman -Qqg base;pacman -Qqg base-devel)|sort)"

  alias aurs="cower -s --color=auto"
  alias auri="pacaur -y"
  alias auru="pacaur -u"

  alias logs="journalctl -f"
fi

##################
### FUNCTIONS ####
##################

man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;37m") \
		LESS_TERMCAP_md=$(printf "\e[1;37m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;47;30m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[0;36m") \
			man "$@"
}

precmd() {
	rehash
}

##################
###### MISC ######
##################

umask 002

##################
### UTILITIES ####
##################

if which dircolors &>/dev/null; then
  eval $(dircolors -b)
fi

if which keychain &> /dev/null; then
  [ "$SSH_AUTH_SOCK" ] || eval $(keychain --eval --agents ssh -Q -q)
fi
