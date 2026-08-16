#!/bin/bash
set -euo pipefail

exec > >(tee output.log) 2>&1

source "utils.sh"

install_apps() {
    BASE_PKGS=(git rsync nano fastfetch greetd greetd-agreety fish github-cli micro ttf-firacode-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra timidity++ mpd mpc ncmpcpp mpdscribble brightnessctl flatpak tree bash-completion uv)
    DESKTOP_PKGS=(wayland niri xorg xwayland-satellite wl-clipboard fuzzel mako foot polkit-gnome xdg-desktop-portal xdg-desktop-portal-gnome gnome-keyring awww swayidle)
    APP_PKGS=(firefox zed nicotine+ nautilus vesktop gimp krita steam celluloid loupe seahorse)

    PACMAN_PKGS=("${BASE_PKGS[@]}" "${DESKTOP_PKGS[@]}" "${APP_PKGS[@]}")
    PARU_PKGS=()
    FLATPAK_PKGS=(io.github.arijanj.Mimic com.stremio.Stremio)

    log "Installing packages..."
    sudo pacman -S --needed "${PACMAN_PKGS[@]}"
    paru -S --needed "${PARU_PKGS[@]}"
    flatpak install -y flathub "${FLATPAK_PKGS[@]}"
    uv tool install beets
    log "Finished installing packages."
}

configure_apps() {
    # mpd doesn't create these itself
    mkdir -p "$HOME/.local/share/mpd/playlists"
    mkdir -p "$HOME/.local/state/mpd"

    local SOURCES=(
        "Pictures/Wallpapers"
        ".config/niri"
        ".config/fastfetch"
        ".config/foot"
        ".config/fuzzel"
        ".config/mako"
        ".config/mpd"
        ".config/beets"
        ".config/ncmpcpp"
    )

    log "Setting up dotfiles..."
    for src in "${SOURCES[@]}"; do
        if [[ -d "giffoni/${src}" ]]; then
            install_dotfile "giffoni/${src}" "$HOME/${src}"
        else
            warn "Source not found, skipping: $src"
        fi
    done

    log "Setting up system config files..."
    sudo cp -vr sys_configs/greetd_config.toml /etc/greetd/config.toml

    log "Enabling services..."
    local USER_SERVICES=(mpd mpdscribble)
    local SYS_SERVICES=(greetd)
    for service in "${USER_SERVICES[@]}"; do
        systemctl --user enable "$service" || warn "Failed to enable $service."
    done
    for service in "${SYS_SERVICES[@]}"; do
        sudo systemctl enable "$service" || warn "Failed to enable $service."
    done

    log "Adding ASCII greeting..."
    sudo cp -vr sys_configs/login_greet.txt /etc/issue
    log "Configuring git..."
    git config --global color.ui auto
    log "Changing user shell to fish..."
    chsh -s /bin/fish
    log "Finished configuring apps."
}

giffoni_related() {
    while true; do
        read -p "Are you Giffoni, and is your HD plugged in? (y/n): " yn
        case $yn in
        [Yy]*)

            log "Configuring git for Giffoni..."
            git config --global user.name "Giffoni Lopes"
            git config --global user.email "kgiffoni_@tuta.com"

            log "Getting external hard drive files..."
            sudo mount /dev/sda1 /mnt
            install_dotfile /mnt/.mpdscribble $HOME/.mpdscribble
            rsync -rtv --progress /mnt/Music/ $HOME/Music/
            rsync -rtv --progress /mnt/Code $HOME/

            log "Unmounting external hard drive..."
            sudo umount /mnt

            break
            ;;
        [Nn]*)
            log "Alrighty then..."
            break
            ;;
        *)
            warn "Please answer yes or no."
            ;;
        esac
    done
}

# grub_tweaks() {
#     log "Tweaking grub config..."

#     # find a line that starts with GRUB_CMDLINE_LINUX_DEFAULT, if it has the word "splash", removes that word
#     sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=.*splash/{
#       s/ splash//
#       s/splash //
#       s/splash//
#     }' /etc/default/grub

#     # find a line that starts with GRUB_TIMEOUT= and replace whatever its value is with, including quotes, '0'
#     sudo sed -i "s/^\(GRUB_TIMEOUT=\).*/\1'0'/" /etc/default/grub

#     log "Applying new grub config..."
#     sudo grub-mkconfig -o /boot/grub/grub.cfg

#     log "Finished tweaking grub."
# }

check_deps pacman paru git awk sudo
install_apps
configure_apps
# not realy using GRUB anymore :p
# grub_tweaks
giffoni_related

log "All done. Restart and enjoy."
