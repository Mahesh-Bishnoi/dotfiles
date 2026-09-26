# Fish mirror of ~/.config/shell/aliases.sh — keep the two in sync.

if command -q eza
    alias ls='eza -al --color=always --group-directories-first --icons=always'
    alias la='eza -a --color=always --group-directories-first --icons=always'
    alias ll='eza -l --color=always --group-directories-first --icons=always'
    alias lt='eza -aT --color=always --group-directories-first --icons=always'
    alias l.="eza -a | grep -e '^\.'"
else
    alias ls='ls --color=auto'
end
alias grep='grep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias jctl='journalctl -p 3 -xb'
alias update='sudo pacman -Syu'
alias mirror='sudo cachyos-rate-mirrors'
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'

alias c='clear'
alias tb='nc termbin.com 9999'
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
# spring-init function already exists as a fish function; no alias needed.
