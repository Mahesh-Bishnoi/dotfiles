#
# ~/.bashrc — interactive bash config.
# Shared env/aliases: ~/.config/shell/env.sh, ~/.config/shell/aliases.sh
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Shared environment + aliases (PATH, EDITOR, DOCKER_HOST, SSH_AUTH_SOCK, PNPM_HOME)
[ -f "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
[ -f "$HOME/.config/shell/aliases.sh" ] && . "$HOME/.config/shell/aliases.sh"

# History: large, append, ignore dups/space-prefixed
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend checkwinsize 2>/dev/null

# Better completion when available
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# mise (node/pnpm/yarn/zoxide/direnv/delta) — replaces nvm
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# Smarter cd + shell hooks (guarded: mise shims may provide these)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Starship prompt (replaces bare PS1; single prompt across bash/zsh/fish)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='[\u@\h \W]\$ '
fi

# Machine specific tweaks (untracked, never committed).
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
