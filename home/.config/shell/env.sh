# Shared POSIX environment for bash + zsh.
# Sourced by ~/.bashrc and ~/.zshrc. Fish uses conf.d/00-env.fish (native mirror).
# Keep this file POSIX-sh compatible: no bashisms, no zshisms.

# --- locale / editor ---
export EDITOR="${EDITOR:-micro}"
export VISUAL="${VISUAL:-micro}"
export PAGER="${PAGER:-less}"
# bat as man pager when available, otherwise plain less
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# --- PATH helpers (dedupe, prepend) ---
path_prepend() {
  # $1 = directory to prepend if it exists and is not already on PATH
  case ":$PATH:" in
    *":$1:"*) return 0 ;;
  esac
  if [ -d "$1" ]; then
    PATH="$1:$PATH"
  fi
}

# Highest priority first. mise/Starship binaries live in ~/.local/bin.
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/go/bin"
# JetBrains Toolbox scripts (was previously only in ~/.profile, invisible to
# non-login shells)
path_prepend "$HOME/.local/share/JetBrains/Toolbox/scripts"
# pnpm home (matches fish config)
export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$PNPM_HOME"

# Collapse pre-existing duplicates (old configs triple-appended ~/.local/bin
# via stacked login+interactive sourcing). Keep first occurrence, drop the rest.
if command -v awk >/dev/null 2>&1; then
  PATH="$(printf '%s' "$PATH" | awk 'BEGIN { RS=":"; ORS=":" } !seen[$0]++')"
  PATH="${PATH%:}"
fi
export PATH

# --- container socket (Podman provides Docker-compatible API) ---
# Portable: derive from XDG_RUNTIME_DIR instead of hardcoding /run/user/1000.
if [ -z "${DOCKER_HOST-}" ] && [ -n "${XDG_RUNTIME_DIR-}" ]; then
  _podman_sock="$XDG_RUNTIME_DIR/podman/podman.sock"
  if [ -S "$_podman_sock" ]; then
    export DOCKER_HOST="unix://$_podman_sock"
  fi
  unset _podman_sock
fi

# --- ssh-agent via systemd socket (user unit, no keychain needed) ---
if [ -z "${SSH_AUTH_SOCK-}" ] && [ -n "${XDG_RUNTIME_DIR-}" ]; then
  if [ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
  fi
fi

# --- version managers ---
# mise is the single manager for node/pnpm/yarn/zoxide/direnv/delta.
# Activation (`mise activate ...`) happens in each shell's rc file.
# SDKMAN remains ONLY for Java (candidates). Do NOT export JAVA_HOME
# statically here: SDKMAN updates it on `sdk use java ...`.
export SDKMAN_DIR="$HOME/.sdkman"
# Bury nvm: if a stale NVM_DIR leaks in (e.g. old universal vars), unset it so
# nothing accidentally loads the slow nvm.sh anymore.
if [ -n "${NVM_DIR-}" ]; then
  case "$NVM_DIR" in
    *".nvm"*) unset NVM_DIR ;;
  esac
fi

# Local secrets (untracked, never committed).
# Put machine only exports in ~/.config/shell/env.local.sh, for example:
#   export CONTEXT7_API_KEY="..."
# That file is ignored by git. See .gitignore.
if [ -f "$HOME/.config/shell/env.local.sh" ]; then
  . "$HOME/.config/shell/env.local.sh"
fi
