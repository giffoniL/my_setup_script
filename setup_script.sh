#!/bin/sh

install_apps() {

  sudo pacman -Syu

  sudo pacman -S --needed fish firefox micro niri wayland xorg xwayland-satellite code foot nicotine+ fuzzel vesktop-bin jdk-openjdk waydroid otf-monaspace swaybg steam timidity++ mpd ncmpcpp mako brightnessctl python python-pipx flatpak tree celluloid loupe darkman fragments errands

  pipx install "beets[fetchart,embedart,lastgenre,scrub,replaygain,thumbnails,info]"
  pipx ensurepath

  paru -S mpd-discord-rpc apple_cursor

  git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git

  ./Reversal-icon-theme/install.sh -t blue

  echo -e "\033[32mFinished installing apps.\033[0m"

}

configure_apps() {

  chsh -s /usr/bin/fish

  mkdir -p $HOME/.local/state/mpd/
  touch $HOME/.local/state/mpd/log

  install -D ./giffoni/Pictures/Wallpaper/wallpaper.jpg $HOME/Pictures/Wallpaper/wallpaper.jpg
  install -D ./giffoni/.ncmpcpp/config $HOME/.ncmpcpp/config
  install -D ./giffoni/.config/beets $HOME/.config/beets
  install -D ./giffoni/.config/darkman/config.yaml $HOME/.config/darkman/config.yaml
  install -D ./giffoni/.config/foot/foot.ini $HOME/.config/foot/foot.ini
  install -D ./giffoni/.config/fuzzel/fuzzel.ini $HOME/.config/fuzzel/fuzzel.ini
  install -D ./giffoni/.config/mako/config $HOME/.config/mako/config
  install -D ./giffoni/.config/mimeapps.list $HOME/.config/mimeapps.list
  install -D ./giffoni/.config/mpd/mpd.conf $HOME/.config/mpd/mpd.conf
  install -D ./giffoni/.config/niri/config.kdl $HOME/.config/niri/config.kdl

    systemctl --user enable --now mako
    systemctl --user enable --now mpd
    systemctl --user enable --now mpd-discord-rpc
    systemctl --user enable --now darkman.service
    
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
