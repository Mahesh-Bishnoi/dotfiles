# ~/.config/fish/config.fish — interactive fish config.
# Env/aliases live in conf.d/00-env.fish + conf.d/01-aliases.fish (auto-loaded
# before this file). Prompt is Starship (single prompt across bash/zsh/fish),
# which overrides the distro-wide pure prompt.

# CachyOS fish defaults (eza aliases, fastfetch greeting). Skipped on
# Ubuntu/Debian/Fedora where the file does not exist.
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# mise (node/pnpm/yarn/zoxide/direnv/delta) — replaces fish-nvm/bass
if command -q mise
    mise activate fish | source
end

# Smarter cd + shell hooks
if command -q zoxide
    zoxide init fish --cmd cd | source
end
if command -q direnv
    direnv hook fish | source
end

# Starship prompt (must run AFTER cachyos-config so it wins over pure)
if command -q starship
    starship init fish | source
end
