#!/bin/bash
set -e

echo "==> Installing base packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm \
    git \
    stow \
    base-devel \
    zsh \
    foot \
    sway \
    waybar \
    dunst \
    tofi \
    yazi \
    fzf \
    eza \
    zoxide \
    starship \
    neovim \
    wl-clipboard \
    cliphist \
    grim \
    slurp \
    brightnessctl \
    pipewire \
    pipewire-pulse \
    wireplumber \
    network-manager-applet \
    networkmanager \
    hyprpicker \
    btop \
    qbittorrent \
    polkit-kde-agent \
    noto-fonts \
    noto-fonts-emoji \
    ttf-noto-nerd

echo "==> Installing yay..."
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
fi

echo "==> Installing AUR packages..."
yay -S --noconfirm \
    awww \
    zsh-syntax-highlighting \
    zsh-fzf-tab \
    helium-browser \
    ly

echo "==> Stowing dotfiles..."
stow -R *

echo "==> Setting default shell to zsh..."
chsh -s $(which zsh)

echo "==> Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable ly

echo "==> Done! Reboot to finish."
