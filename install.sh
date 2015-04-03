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
  has $1 && return 0
  has ruby || exit_error Ruby is not available. Unable to install HomeBrew.
  has brew || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  has brew || exit_error Failed to install HomeBrew.
  brew install $1
}

PACMAN_UPDATED=0
pacman_install() {
  has $1 && return 0
  has_sudo || exit_error Sudo is not available.
  [ $PACMAN_UPDATED -eq 1 ] || sudo pacman -Sy
  PACMAN_UPDATED=1
  sudo pacman -S $1
}

APT_GET_UPDATED=0
apt_install() {
  has $1 && return 0
  has_sudo || exit_error Sudo is not available.
  [ $APT_GET_UPDATED -eq 1 ] || sudo apt-get update
  APT_GET_UPDATED=1
  sudo apt-get install --no-install-recommends -y $1
}

case $DISTRO in
OSX)
  has git || brew_install git
  has zsh || brew_install zsh
  ;;
ArchLinux)
  has git || pacman_install git
  has zsh || pacman_install zsh
  ;;
Debian | Ubuntu)
  has git || apt_install git-core
  has zsh || apt_install zsh
  ;;
esac

has git || exit_error Failed to install git.
has zsh || exit_error Failed to install zsh.

if ! [ "$SHELL" = "$(which zsh)" ]; then
  if has_sudo; then
    sudo chsh -s $(which zsh) $(whoami)
  else
    echo chsh -s $(which zsh) || echo Unable to change shell for $(whoami). Please run the following command manually: && echo chsh -s $(which zsh)
  fi
fi

ZGEN_DIR=~/.local/share/zgen
ZSHRC=~/.zshrc

[ -d "${ZGEN_DIR}" ] || git clone https://github.com/tarjoilija/zgen.git ${ZGEN_DIR}
chmod -R go-w ${ZGEN_DIR}

[ -f "${ZSHRC}" ] && mv ${ZSHRC} ${ZSHRC}.bak.$(date +%s)

cat > ${ZSHRC} <<END
source ${ZGEN_DIR}/zgen.zsh

if ! zgen saved; then
    zgen load markusmattinen/zsh-config
    zgen load nojhan/liquidprompt

    zgen save
fi
END

zsh -c "source ${ZSHRC} && which zgen &>/dev/null && zgen update"
)
