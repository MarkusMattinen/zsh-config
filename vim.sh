#!/bin/sh

(
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

set -eo pipefail

brew_install() {
  has ruby || exit_error Ruby is not available. Unable to install HomeBrew.
  has brew || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  has brew || exit_error Failed to install HomeBrew.
  brew install $1
}

PACMAN_UPDATED=0
pacman_install() {
  has_sudo || exit_error Sudo is not available.
  [ $PACMAN_UPDATED -eq 1 ] || sudo pacman -Sy
  PACMAN_UPDATED=1
  sudo pacman -S --noconfirm $1
}

APT_GET_UPDATED=0
apt_install() {
  has_sudo || exit_error Sudo is not available.
  [ $APT_GET_UPDATED -eq 1 ] || sudo apt-get update
  APT_GET_UPDATED=1
  sudo apt-get install --no-install-recommends -y $1
}

case $DISTRO in
OSX)
  has vim || brew_install vim
  ;;
ArchLinux)
  has vim || pacman_install vim
  ;;
Debian | Ubuntu)
  has vim || apt_install vim
  ;;
esac

VIMRC_LOCAL=~/.vimrc.local
VIMRC_BEFORE_LOCAL=~/.vimrc.before.local

cat > ${VIMRC_LOCAL}.new <<END
set shiftwidth=2
set tabstop=2
set softtabstop=2
set background=light
let g:solarized_termcolors=16
colorscheme solarized
END

grep colorscheme ${VIMRC_LOCAL} &>/dev/null || mv ${VIMRC_LOCAL} ${VIMRC_LOCAL}.bak.$(date +%s) &>/dev/null || true
mv ${VIMRC_LOCAL}.new ${VIMRC_LOCAL}

cat > ${VIMRC_BEFORE_LOCAL}.new <<END
let g:spf13_bundle_groups=['general', 'writing', 'programming', 'go', 'ruby', 'python', 'javascript', 'html', 'misc']
END

grep bundle_groups ${VIMRC_BEFORE_LOCAL} &>/dev/null || mv ${VIMRC_BEFORE_LOCAL} ${VIMRC_BEFORE_LOCAL}.bak.$(date +%s) &>/dev/null || true
mv ${VIMRC_BEFORE_LOCAL}.new ${VIMRC_BEFORE_LOCAL}

curl http://j.mp/spf13-vim3 -L -o - | sh
)
