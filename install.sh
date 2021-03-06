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

function finalize() {
  popd &>/dev/null
}

pushd $HOME &>/dev/null && trap finalize EXIT

confirm() {
  read -p "$@" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$  ]]; then
    return 0
  else
    return 1
  fi
}

if confirm "Install the script author's SSH public key into authorized keys file? (y/N)"; then
  AUTHORIZED_KEYS_FILE=~/.ssh/authorized_keys
  mkdir -p "$(dirname "$AUTHORIZED_KEYS_FILE")"
  touch "$AUTHORIZED_KEYS_FILE"
  chmod 700 "$(dirname "$AUTHORIZED_KEYS_FILE")"
  chmod 600 "$AUTHORIZED_KEYS_FILE"
  PUBKEY="$(curl https://qj.fi/id_rsa.pub)"
  grep "PUBKEY" "$AUTHORIZED_KEYS_FILE" || echo "$PUBKEY" >> "$AUTHORIZED_KEYS_FILE"
fi

brew_install() {
  confirm "Install $@ with HomeBrew?" || return 0
  has ruby || exit_error Ruby is not available. Unable to install HomeBrew.
  has brew || confirm "Install HomeBrew?" || return 0
  has brew || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  has brew || exit_error Failed to install HomeBrew.
  brew install $@
}

cask_install() {
  confirm "Install $@ with brew-cask?" || return 0
  has brew-cask || brew_install caskroom/cask/brew-cask
  has brew-cask || exit_error Failed to install HomeBrew.
  brew cask install $@
}

PACMAN_UPDATED=0
pacman_install() {
  confirm "Install $@ with pacman?" || return 0
  has_sudo || exit_error Sudo is not available.
  [ $PACMAN_UPDATED -eq 1 ] || sudo pacman -Sy
  PACMAN_UPDATED=1
  sudo pacman -S --noconfirm $@
}

APT_GET_UPDATED=0
apt_install() {
  confirm "Install $@ with apt-get?" || return 0
  has_sudo || exit_error Sudo is not available.
  [ $APT_GET_UPDATED -eq 1 ] || sudo apt-get update
  APT_GET_UPDATED=1
  sudo apt-get install --no-install-recommends -y $@
}

case $DISTRO in
OSX)
  has git || brew_install git
  has zsh || brew_install zsh
  has htop || brew_install htop
  ;;
ArchLinux)
  has git || pacman_install git
  has zsh || pacman_install zsh
  has htop || pacman_install htop
  ;;
Debian | Ubuntu)
  has git || apt_install git-core
  has zsh || apt_install zsh
  has htop || apt_install htop
  ;;
esac

if [ ! "$SHELL" = "$(which zsh)" ]; then
  if has_sudo; then
    sudo chsh -s $(which zsh) $(whoami)
  else
    chsh -s $(which zsh) || echo Unable to change shell for $(whoami). Please run the following command manually: && echo -- chsh -s $(which zsh)
  fi
fi

ZGEN_DIR=~/.local/share/zgen
ZSHRC=~/.zshrc

[ -d "${ZGEN_DIR}" ] || git clone https://github.com/tarjoilija/zgen.git ${ZGEN_DIR}
chmod -R go-w ${ZGEN_DIR}

cat > ${ZSHRC}.new <<END
DISABLE_AUTO_UPDATE=true
source ${ZGEN_DIR}/zgen.zsh

if ! zgen saved; then
    zgen oh-my-zsh
    zgen oh-my-zsh plugins/last-working-dir
END

case $DISTRO in
OSX)
  echo '    zgen oh-my-zsh plugins/web-search' >> ${ZSHRC}.new
  ;;
ArchLinux)
  ;;
Ubuntu)
  ;;
esac

cat >> ${ZSHRC}.new <<END
    zgen load markusmattinen/zsh-config
    zgen load nojhan/liquidprompt

    zgen save
fi
END

grep markusmattinen ${ZSHRC} &>/dev/null || mv ${ZSHRC} ${ZSHRC}.bak.$(date +%s) &>/dev/null || true
mv ${ZSHRC}.new ${ZSHRC}

zsh -c "source ${ZSHRC} && which zgen &>/dev/null && zgen update"
)
