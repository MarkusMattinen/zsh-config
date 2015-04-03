TARGETS = install.sh \
          zsh-config.plugin.zsh

all: $(TARGETS)

install.sh: hashbang.sh.tmpl subshell.pre.sh.tmpl common.sh.tmpl install.sh.tmpl subshell.post.sh.tmpl
	cat $^ >$@

zsh-config.plugin.zsh: hashbang.zsh.tmpl common.sh.tmpl zsh-config.plugin.zsh.tmpl
	cat $^ >$@

clean:
	rm -f $(TARGETS)
