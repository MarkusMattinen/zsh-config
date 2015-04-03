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

set -eo pipefail

brew_install() {
  has brew || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  has brew || (echo Failed to install HomeBrew. && exit 1)
  brew install $@
}

pacman_install() {
  sudo -nv 2>&1 | egrep ".*may not run sudo.*" && exit 1 || true
  sudo pacman -Sy $@
}

apt_install() {
  sudo -nv 2>&1 | egrep ".*may not run sudo.*" && exit 1 || true
  sudo apt-get update && apt-get install --no-install-recommends -y $@
}

has() {
  which $@ &>/dev/null
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

has git || (echo Failed to install git. Exiting. && exit 1)
has zsh || (echo Failed to install zsh. Exiting. && exit 1)

[ "$SHELL" = "$(which zsh)" ] || chsh -s $(which zsh)

ZGEN_DIR=~/.local/share/zgen
ZSHRC=~/.zshrc

[ -d "${ZGEN_DIR}" ] || git clone https://github.com/tarjoilija/zgen.git ${ZGEN_DIR}
chmod -R go-w ${ZGEN_DIR}

[ -f "${ZSHRC}" ] && mv ${ZSHRC} ${ZSHRC}.bak.$(date +%s)

> ${ZSHRC} <<END
source ${ZGEN_DIR}/zgen.zsh

if ! zgen saved; then
    zgen load markusmattinen/zsh-config
    zgen load nojhan/liquidprompt

    zgen save
fi
END
)
