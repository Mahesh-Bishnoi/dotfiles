#!/usr/bin/env bash
#
# bootstrap.sh — turn a fresh CachyOS / Ubuntu / Debian / Fedora machine into
# this dotfiles repo's environment.
#
#   git clone https://github.com/Mahesh-Bishnoi/dotfiles.git ~/code/dotfiles
#   cd ~/code/dotfiles && ./bootstrap.sh
#
# Flags:
#   --links-only   only (re)create symlinks, skip package/tool installation
#   --no-packages  skip OS package installation (still installs mise/starship/…)
#   -y             don't ask before overwriting (backs up to *.bak-dotfiles-*)
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX="bak-dotfiles-$(date +%Y%m%d%H%M%S)"
ASSUME_YES=0
LINKS_ONLY=0
NO_PACKAGES=0
for arg in "$@"; do
  case "$arg" in
    -y) ASSUME_YES=1 ;;
    --links-only) LINKS_ONLY=1 ;;
    --no-packages) NO_PACKAGES=1 ;;
    -h|--help)
      echo "usage: bootstrap.sh [-y] [--links-only] [--no-packages]"; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m=?>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mXX\033[0m %s\n' "$*" >&2; exit 1; }

os_id() { # prints: arch | debian | fedora
  local id like
  id="$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')"
  like="$(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"' || true)"
  case "$id $like" in
    *arch*)    echo arch ;;
    *debian*|*ubuntu*) echo debian ;;
    *fedora*|*rhel*|*centos*) echo fedora ;;
    *) die "unsupported OS ($id). Supported: CachyOS/Arch, Ubuntu, Debian, Fedora." ;;
  esac
}

install_packages() {
  local os="$1"
  case "$os" in
    arch)
      if command -v paru >/dev/null; then
        sudo paru -S --needed --noconfirm $(grep -v '^#' "$REPO/packages/arch.txt" | tr '\n' ' ')
      else
        warn "paru not found, using pacman (github-cli skipped if unavailable)"
        sudo pacman -S --needed --noconfirm $(grep -v '^#' "$REPO/packages/arch.txt" | grep -v '^github-cli$' | tr '\n' ' ')
      fi
      ;;
    debian)
      sudo apt-get update
      sudo apt-get install -y $(grep -v '^#' "$REPO/packages/debian.txt" | tr '\n' ' ')
      # Debian/Ubuntu call it batcat — normalise to `bat` for our configs
      if ! command -v bat >/dev/null && command -v batcat >/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
        log "linked ~/.local/bin/bat -> batcat"
      fi
      ;;
    fedora)
      sudo dnf install -y $(grep -v '^#' "$REPO/packages/fedora.txt" | tr '\n' ' ')
      ;;
  esac
}

install_mise() {
  if command -v mise >/dev/null; then log "mise already installed"; return; fi
  log "installing mise to ~/.local/bin"
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
}

install_starship() {
  if command -v starship >/dev/null || [ -x "$HOME/.local/bin/starship" ]; then
    log "starship already installed"; return
  fi
  log "installing starship to ~/.local/bin"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes -b "$HOME/.local/bin"
}

install_opencode() {
  if command -v opencode >/dev/null; then log "opencode already installed"; return; fi
  log "installing opencode"
  curl -fsSL https://opencode.ai/install | bash
  export PATH="$HOME/.local/bin:$PATH"
}

install_sdkman() {
  if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then log "SDKMAN already installed"; return; fi
  log "installing SDKMAN (Java via SDKMAN; node via mise)"
  curl -s "https://get.sdkman.io" | bash
}

install_fisher_sdkman_fish() {
  command -v fish >/dev/null || return 0
  if fish -c 'functions -q sdk' 2>/dev/null; then log "fish sdkman plugin present"; return; fi
  log "installing fisher + sdkman-for-fish"
  fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher reitzig/sdkman-for-fish@v2.1.0' \
    || warn "fisher install failed (offline?) — fish Java support skipped"
}

link_file() { # link_file <repo-relative-path-under-home/>
  local src="$REPO/home/$1" dst="$HOME/$1"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return 0; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$ASSUME_YES" = 1 ]; then
      mv "$dst" "$dst.$BACKUP_SUFFIX"
      log "backed up $dst -> $dst.$BACKUP_SUFFIX"
    else
      read -r -p "overwrite $dst? [y/N] " ans
      case "$ans" in
        y|Y) mv "$dst" "$dst.$BACKUP_SUFFIX"; log "backed up $dst" ;;
        *) warn "skipped $dst"; return 0 ;;
      esac
    fi
  fi
  ln -s "$src" "$dst"
  log "linked $dst"
}

setup_ssh() {
  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    log "generating new ed25519 SSH key (no passphrase — press enter if asked)"
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
  else
    log "SSH key already exists"
  fi
  chmod 700 "$HOME/.ssh"
  chmod 600 "$HOME/.ssh/id_ed25519" "$HOME/.ssh/config" 2>/dev/null || true
  chmod 644 "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
  # allowed_signers is per-machine (fresh key per machine) — generated, not committed
  {
    echo "$(git config --global user.email 2>/dev/null || echo "$USER@$(hostname)") $(cat "$HOME/.ssh/id_ed25519.pub")"
  } > "$HOME/.ssh/allowed_signers"
  chmod 600 "$HOME/.ssh/allowed_signers"
  log "wrote ~/.ssh/allowed_signers"
}

verify() {
  export PATH="$HOME/.local/bin:$PATH"
  log "verification"
  command -v git mise starship >/dev/null && echo "  core tools: OK"
  eval "$(mise activate bash)" 2>/dev/null || true
  mise install 2>&1 | tail -1
  bash -c 'eval "$(mise activate bash)"; node --version' 2>/dev/null || warn "mise node not ready"
  bash -ic 'echo $STARSHIP_SHELL' 2>/dev/null | grep -q bash && echo "  bash+starship: OK" || warn "bash starship check inconclusive (non-interactive)"
  fish -ic 'echo $STARSHIP_SHELL' 2>/dev/null | grep -q fish && echo "  fish+starship: OK" || warn "fish check skipped"
  zsh -ic 'echo $STARSHIP_SHELL' 2>/dev/null | grep -q zsh && echo "  zsh+starship: OK" || warn "zsh check skipped"
}

main() {
  local os
  os="$(os_id)"
  log "OS family: $os"

  if [ "$LINKS_ONLY" = 0 ]; then
    if [ "$NO_PACKAGES" = 0 ]; then install_packages "$os"; else log "skipping OS packages"; fi
    install_mise
    install_starship
    install_opencode
    install_sdkman
    install_fisher_sdkman_fish
  fi

  log "linking dotfiles"
  for f in \
    .bashrc .zshrc .profile .gitconfig \
    .config/shell/env.sh .config/shell/aliases.sh \
    .config/starship.toml \
    .config/git/ignore \
    .config/fish/config.fish .config/fish/conf.d/00-env.fish .config/fish/conf.d/01-aliases.fish \
    .config/alacritty/alacritty.toml \
    .config/micro/settings.json \
    .config/mise/config.toml \
    .config/opencode/cli.json .config/opencode/dcp.jsonc .config/opencode/opencode.jsonc .config/opencode/package.json \
    .ssh/config \
  ; do link_file "$f"; done

  setup_ssh

  if [ "$LINKS_ONLY" = 0 ]; then verify; fi

  cat <<'EOF'

Done. Remaining manual steps (with links):
  1. GitHub -> Settings -> SSH and GPG keys: add ~/.ssh/id_ed25519.pub twice,
     once as "Authentication Key" and once as "Signing Key".
  2. gh auth login   (browser flow; replaces git credential cache)
  3. Java:  sdk install java 25.0.1-tem   (then: sdk default java 25.0.1-tem)
  4. opencode:  opencode auth login   (per provider)
  5. Restart your terminal. Fish users: fisher plugins sync on first start.
EOF
}
main "$@"
