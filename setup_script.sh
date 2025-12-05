#!/bin/sh

install_apps() {

  sudo pacman -Syu

  sudo pacman -S --needed firefox micro niri wayland xorg xwayland-satellite code ghostty nicotine+ rofi vesktop-bin jdk-openjdk waydroid otf-monaspace inter-font swaybg swayimg steam timidity++ mpd ncmpcp gnome-themes-extra sassc mako brightnessctl python python-pipx

  pipx install beets
  pipx install beets[fetchart]
  pipx install beets[embedart]
  pipx install beets[lastgenre]

  paru -S mpd-discord-rpc

  git clone https://github.com/vinceliuice/Orchis-theme.git

  ./Orchis-theme/install.sh -l

  git clone https://github.com/vinceliuice/Tela-icon-theme.git

  ./Tela-icon-theme/install.sh

  echo -e "\033[32mFinished installing apps.\033[0m"

}

configure_apps() {

    chsh -s /usr/bin/bash

    mkdir -p $HOME/.config/
    cp -vr ./.config/* $HOME/.config/
    cp -vr ./giffoni/* $HOME/

    cp -vr ./Pictures/* $HOME/Pictures/

    cp -vr ./audio_stuff/.mpd $HOME/
    cp -vr ./audio_stuff/.ncmpcpp $HOME/
    cp -vr ./audio_stuff/mpd $HOME/.config/

    systemctl --user enable --now mpd
    systemctl --user enable --now mpd-discord-rpc
    
    git config --global color.ui auto
    git config --global user.name "Giffoni Lopes"
    git config --global user.email "kgiffoni_@tuta.com"


    echo -e "\033[32mFinished configuring apps.\033[0m"

}

edit_grub() {
  NEW_PARAMS="cpufreq.default_governor=performance intel_pstate=disable"
  sudo awk -v new_params="$NEW_PARAMS" '
    /^GRUB_CMDLINE_LINUX_DEFAULT=/ {
      match($0, /'\''(.*)'\''/, a)
      current=a[1]
      $0 = "GRUB_CMDLINE_LINUX_DEFAULT='\''" current " " new_params "'\''"
    }
    /^GRUB_TIMEOUT=/ {
      $0 = "GRUB_TIMEOUT='\''0'\''"
    }
    {print}
  ' /etc/default/grub > /tmp/grub.new && sudo mv /tmp/grub.new /etc/default/grub

  sudo grub-mkconfig -o /boot/grub/grub.cfg

  echo -e "\033[32mFinished configuring grub.\033[0m"

}




install_apps

configure_apps

edit_grub



echo -e "\033[32mAll done. Restart and enjoy.\033[0m"
