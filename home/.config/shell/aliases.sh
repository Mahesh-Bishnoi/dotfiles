# Shared POSIX aliases for bash + zsh.
# Fish equivalents live in ~/.config/fish/conf.d/01-aliases.fish.
# Guard each alias so re-sourcing (login + interactive) is harmless.

# --- eza (matches CachyOS fish defaults) ---
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -al --color=always --group-directories-first --icons=always'
  alias la='eza -a --color=always --group-directories-first --icons=always'
  alias ll='eza -l --color=always --group-directories-first --icons=always'
  alias lt='eza -aT --color=always --group-directories-first --icons=always'
  alias l.="eza -a | grep -e '^\.'"
else
  alias ls='ls --color=auto'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# --- navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- Arch / CachyOS helpers (sudo-gated, safe as aliases) ---
alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias cleanup='sudo pacman -Rsn $(pacman -Qtdq)'
alias jctl='journalctl -p 3 -xb'
alias update='sudo pacman -Syu'
alias mirror='sudo cachyos-rate-mirrors'
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'

# --- misc ---
alias c='clear'
alias tb='nc termbin.com 9999'
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias spring-init="$HOME/code/spring-initializr-tui/target/spring-initializr-tui"
