#!/bin/bash
set -euo pipefail

exec > >(tee output.log) 2>&1

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING]: $1${NC}"
}

error() {
    echo -e "${RED}[ERROR]: $1${NC}"
    exit 1
}

check_deps() {
    local missing=()

    for bin in "$@"; do
        if ! command -v "$bin" >/dev/null 2>&1; then
            missing+=("$bin")
        fi
    done

    if [[ ${#missing[@]} -ne 0 ]]; then
        warn "FATAL: The following dependencies are missing:"
        for item in "${missing[@]}"; do
            warn "  - $item"
        done
        error "Please install them and run the script again."
    fi
}

install_apps() {
    BASE_PKGS=(git rsync nano fastfetch greetd greetd-agreety fish fisher github-cli micro jdk-openjdk shfmt otf-monaspace-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra timidity++ mpd mpc rmpc mpdscribble brightnessctl flatpak tree beets bash-completion chromaprint ffmpeg gst-plugins-bad gst-plugins-good gst-plugins-ugly gst-libav gst-python imagemagick python-beautifulsoup4 python-discogs-client python-flask python-gobject python-langdetect python-librosa python-mpd2 python-pyacoustid python-pylast python-requests-oauthlib python-xdg python-titlecase)
    DESKTOP_PKGS=(wayland niri xorg xwayland-satellite wl-clipboard fuzzel mako foot polkit-gnome xdg-desktop-portal xdg-desktop-portal-gnome gnome-keyring awww seahorse)
    APP_PKGS=(zed nicotine+ nautilus vesktop gimp waydroid steam celluloid loupe fragments obsidian)

    PACMAN_PKGS=("${BASE_PKGS[@]}" "${DESKTOP_PKGS[@]}" "${APP_PKGS[@]}")
    PARU_PKGS=(mpd-discord-rpc)
    FLATPAK_PKGS=(io.github.arijanj.Mimic com.stremio.Stremio)

    log "Installing packages..."
    sudo pacman -Syu --needed "${PACMAN_PKGS[@]}"
    paru -S --needed "${PARU_PKGS[@]}"
    flatpak install -y flathub "${FLATPAK_PKGS[@]}"
    fish -c 'fisher install pure-fish/pure' # i just use this package...

    log "Finished installing apps."
}

configure_apps() {

    # gotta make these folders because mpd doesn't like doing them itself for some reason
    mkdir -p $HOME/.local/share/mpd/playlists
    mkdir -p $HOME/.local/state/mpd

    SOURCES=(
        "Pictures/Wallpapers/"
        ".config/niri/"
        ".config/rmpc/"
        ".config/fastfetch/"
        ".config/foot/foot.ini"
        ".config/fuzzel/fuzzel.ini"
        ".config/mako/config"
        ".config/mpd/mpd.conf"
    )

    log "Setting up dotfiles..."
    for src in "${SOURCES[@]}"; do
        dest="$HOME/${src}"
        if [[ -f "giffoni/${src}" ]]; then
            install -Dv "giffoni/${src}" "$dest" || { warn "Failed to install $dest"; }
        elif [[ -d "giffoni/${src}" ]]; then
            mkdir -p "$dest"
            cp -rv "giffoni/${src}/." "$dest" || { warn "Failed to copy $dest"; }
        else
            warn "Source not found, skipping: $src"
        fi
    done

    # sys sources here, i should probably clean this up later if more are ever needed
    log "Setting up system config files..."
    sudo cp -vr sys_configs/greetd_config.toml /etc/greetd/config.toml

    log "Enabling services..."
    if systemctl --user list-units >/dev/null 2>&1; then
        USER_SERVICES=(mpd mpd-discord-rpc mpdscribble)
        SYS_SERVICES=(greetd)
        for service in "${USER_SERVICES[@]}"; do
            systemctl --user enable "$service" || warn "Failed to enable $service."
        done
        for service in "${SYS_SERVICES[@]}"; do
            sudo systemctl enable "$service" || warn "Failed to enable $service."
        done
    fi

    log "Adding ASCII greeting..."
    sudo cp -v login_greet.txt /etc/issue

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
            install -Dv /mnt/.mpdscribble/mpdscribble.conf $HOME/.mpdscribble/mpdscribble.conf
            install -Dv /mnt/beets/config.yaml $HOME/.config/beets/config.yaml
            cp -rv /mnt/Code $HOME/
            cp -rv /mnt/Music/. $HOME/Music/

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

grub_tweaks() {
    log "Tweaking grub config..."

    # find a line that starts with GRUB_CMDLINE_LINUX_DEFAULT, if it has the word "splash", remove it
    sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=.*splash/{
      s/ splash//
      s/splash //
      s/splash//
    }' /etc/default/grub

    # find a line that starts with GRUB_TIMEOUT= and replace whatever its value is with, including quotes, '0'
    sudo sed -i "s/^\(GRUB_TIMEOUT=\).*/\1'0'/" /etc/default/grub

    log "Applying new grub config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    log "Finished tweaking grub."
}

check_deps pacman paru git awk sudo
install_apps
giffoni_related
configure_apps
grub_tweaks

log "All done. Restart and enjoy."
