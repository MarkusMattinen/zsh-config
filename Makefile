TARGETS = install.sh \
					zsh-config.plugin.zsh \
					vim.sh \
					create-user.sh

all: $(TARGETS)

install.sh: hashbang.sh.tmpl subshell.pre.sh.tmpl common.sh.tmpl install.sh.tmpl subshell.post.sh.tmpl
	cat $^ >$@

vim.sh: hashbang.sh.tmpl subshell.pre.sh.tmpl common.sh.tmpl vim.sh.tmpl subshell.post.sh.tmpl
	cat $^ >$@

zsh-config.plugin.zsh: hashbang.zsh.tmpl common.sh.tmpl zsh-config.plugin.zsh.tmpl
	cat $^ >$@

create-user.sh: hashbang.sh.tmpl subshell.pre.sh.tmpl common.sh.tmpl create-user.sh.tmpl subshell.post.sh.tmpl
	cat $^ >$@

clean:
	rm -f $(TARGETS)
