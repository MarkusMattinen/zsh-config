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

USERNAME=markus

case $DISTRO in
OSX)
  exit_error Not supported.
  ;;
ArchLinux)
  useradd -mUG wheel $USERNAME
  ;;
Ubuntu | Debian)
  useradd -mUG sudo $USERNAME
  ;;
esac

AUTHORIZED_KEYS_FILE="/home/$USERNAME/.ssh/authorized_keys"
PUBKEY="$(curl https://qj.fi/id_rsa.pub)"
grep "PUBKEY" "$AUTHORIZED_KEYS_FILE" || echo "$PUBKEY" >> "$AUTHORIZED_KEYS_FILE"

curl https://qj.fi/zsh | sudo -su $USERNAME 
)
