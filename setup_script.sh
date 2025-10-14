#!/bin/sh

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

  echo "Finished configuring grub."
}


install_apps() {

  sudo pacman -Syu

  sudo pacman -S --needed firefox-developer-edition micro niri wayland xorg xwayland-satellite code foot nicotine+ rofi vesktop-bin jdk-openjdk waydroid ttf-input-nerd inter-font starship swaybg swayimg steam capitaine-cursors timidity++ mpd ncmpcpp

  paru -S --needed mojave-gtk-theme-git mcmojave

  git clone https://github.com/vinceliuice/McMojave-circle.git

  ./McMojave-circle/install.sh

  echo "Finished installing apps."

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

    cp -vr ".audio_stuff/.mpd" "$HOME/"
    cp -vr ".audio_stuff/.ncmpcpp" "$HOME/"
    cp -vr ".audio_stuff/mpd" "$HOME/.config/"


    cp -vr "./wallpaper.jpg" "$HOME/Pictures/"

    echo "Finished configuring apps."

}




install_apps

configure_apps

edit_grub



echo "All done. Restart and enjoy."
