#!/bin/sh

install_apps() {

  sudo pacman -Syu

  sudo pacman -S --needed niri wayland xorg xwayland-satellite rhythmbox vscodium foot nicotine+ rofi vesktop-bin jdk-openjdk waydroid ttf-firacode-nerd inter-font starship orchis-theme swaybg swayimg steam tela-circle-icon-theme-all capitaine-cursors

}

configure_apps() {

    chsh -s /usr/bin/bash

    mkdir -p "$HOME/.config/niri" "$HOME/.config/foot" 

    git config --global color.ui auto
    git config --global user.name "Giffoni Lopes"
    git config --global user.email "kgiffoni_@tuta.com"


    starship preset bracketed-segments -o ~/.config/starship.toml

    cp -vr "./niri-config.kdl" "$HOME/.config/niri/config.kdl"
    cp -vr "./foot-config.ini" "$HOME/.config/foot/foot.ini"

    cp -vr "./wallpaper.jpeg" "$HOME/Pictures/"

    codium --install-extension monokai.theme-monokai-pro-vscode
    codium --install-extension syler.sass-indented
    codium --install-extension vscjava.vscode-java-pack
    codium --install-extension vmware.vscode-boot-dev-pack
    codium --install-extension ms-python.python
    codium --install-extension batisteo.vscode-django



}


install_apps

configure_apps

echo "All done."
