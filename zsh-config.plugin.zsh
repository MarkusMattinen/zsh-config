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

setopt nobeep
setopt kshglob
setopt nonomatch

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
###### MISC ######
##################

umask 022

##################
### UTILITIES ####
##################

if which keychain &> /dev/null; then
  [ "$SSH_AUTH_SOCK" ] || eval $(keychain --eval --agents ssh -Q -q)
fi
