# ~/.profile — sourced by display managers and login shells.
# Interactive shells get everything from ~/.bashrc / ~/.zshrc / fish conf.d,
# which source ~/.config/shell/env.sh. This file stays minimal so PATH and
# version managers are identical in graphical and terminal logins.

# JetBrains Toolbox scripts are also prepended in env.sh; keep this append as
# a fallback for minimal-PATH display-manager sessions.
case ":$PATH:" in
  *":$HOME/.local/share/JetBrains/Toolbox/scripts:"*) ;;
  *) export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts" ;;
esac

# Node is managed by mise (activated per-shell). nvm removed 2026-09-26.
