# ~/.zshrc — interactive zsh config.
# Prompt is Starship (single prompt across bash/zsh/fish).
# CachyOS base still loads oh-my-zsh + p10k theme; Starship init below
# overrides PROMPT/RPROMPT so p10k theme code is inert. Keeping the base
# source preserves distro plugin updates (syntax-highlighting,
# autosuggestions, history-substring-search, fzf plugin).

# Reduce p10k overhead since Starship owns the prompt now.
export POWERLEVEL9K_INSTANT_PROMPT=off
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# CachyOS base (oh-my-zsh + plugins). On Ubuntu/Debian/Fedora this file does
# not exist — fall back to a minimal portable setup.
if [ -f /usr/share/cachyos-zsh-config/cachyos-config.zsh ]; then
  source /usr/share/cachyos-zsh-config/cachyos-config.zsh
else
  autoload -Uz compinit && compinit
  HISTSIZE=10000
  SAVEHIST=10000
  setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE 2>/dev/null
  # syntax highlighting / autosuggestions when the distro ships them
  [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [ -f /usr/share/doc/pkgfile/command-not-found.zsh ] && \
    . /usr/share/doc/pkgfile/command-not-found.zsh
fi

# Shared environment + aliases (PATH, EDITOR, DOCKER_HOST, SSH_AUTH_SOCK, PNPM_HOME)
[ -f "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
[ -f "$HOME/.config/shell/aliases.sh" ] && . "$HOME/.config/shell/aliases.sh"

# History tuning on top of oh-my-zsh defaults
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export SAVEHIST=10000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE 2>/dev/null

# mise (node/pnpm/yarn/zoxide/direnv/delta) — replaces nvm
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Smarter cd + shell hooks
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Starship prompt (must run AFTER cachyos-config/p10k so it wins)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# spring-initializr-tui helper
alias spring-init="$HOME/code/spring-initializr-tui/target/spring-initializr-tui"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
