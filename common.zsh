#!/bin/zsh

##################
## OS DETECTION ##
##################

OS=Unknown

OSNAME="$(uname -s)"
case $OSNAME in
Linux)
  OS=Linux
  ;;
Darwin)
  OS=OSX
  ;;
esac

DISTRO=Unknown

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

