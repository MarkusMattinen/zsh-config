#!/bin/sh

sudo git clone git@github.com:tarjoilija/zgen.git /usr/local/share/zgen

[ -f "~/.zshrc" ] && mv ~/.zshrc ~/.zshrc.bak.$(date +%s)

> ~/.zshrc <<END
source /usr/share/zgen/zgen.zsh

if ! zgen saved; then
    zgen load markusmattinen/zsh-config
    zgen load nojhan/liquidprompt

    zgen save
fi
END
