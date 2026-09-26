# Fish mirror of ~/.config/shell/env.sh — keep the two in sync.
# Runs on every interactive fish start via conf.d.

# --- locale / editor ---
set -q EDITOR; or set -gx EDITOR micro
set -q VISUAL; or set -gx VISUAL micro
set -q PAGER; or set -gx PAGER less
if command -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx MANROFFOPT "-c"
end

# --- PATH (dedupe + prepend, highest priority first) ---
fish_add_path --prepend --move ~/.local/bin ~/.cargo/bin ~/go/bin \
    ~/.local/share/JetBrains/Toolbox/scripts

# pnpm home (matches env.sh)
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
fish_add_path --prepend --move "$PNPM_HOME"

# --- container socket (guard: only when socket exists) ---
if test -z "$DOCKER_HOST"; and test -n "$XDG_RUNTIME_DIR"
    if test -S "$XDG_RUNTIME_DIR/podman/podman.sock"
        set -gx DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    end
end

# --- ssh-agent via systemd socket ---
if test -z "$SSH_AUTH_SOCK"; and test -n "$XDG_RUNTIME_DIR"
    if test -S "$XDG_RUNTIME_DIR/ssh-agent.socket"
        set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    end
end

# --- version managers ---
# mise owns node/pnpm/yarn/zoxide/direnv/delta; SDKMAN owns Java only.
set -gx SDKMAN_DIR "$HOME/.sdkman"
# Bury nvm leftovers so nothing loads the slow nvm.sh anymore.
set -e NVM_DIR 2>/dev/null
# Drop stale universal DOCKER_HOST baked by old config (now set above).
# (Only runs if the universal var exists from before this migration.)
if set -qU DOCKER_HOST
    set -eU DOCKER_HOST
end
