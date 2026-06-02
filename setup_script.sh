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

# usage: install_dotfile dotfile_source_dir dotfile_dest_dir
install_dotfile() {
    local src="${1%/}"
    local dest="${2%/}"

    [[ ! -d "$src" ]] && {
        error "Source must be a directory."
    }
    [[ "$src" -ef "$dest" ]] && {
        error "Source and destination must differ."
    }

    mkdir -p "$dest"

    shopt -s dotglob nullglob

    for dest_file in "$dest"/*; do
        local backup="${dest_file}.bak.$(date +%Y%m%d%H%M%S)"
        log "Backing up $dest_file -> $backup"
        mv "$dest_file" "$backup"
    done

    shopt -u dotglob nullglob

    cp -vr "$src/." "$dest"
}

check_deps() {
    local missing=()

    for bin in "$@"; do
        if ! command -v "$bin" >/dev/null 2>&1; then
            missing+=("$bin")
        fi
    done

    if [[ ${#missing[@]} -ne 0 ]]; then
        warn "The following dependencies are missing:"
        for item in "${missing[@]}"; do
            warn "  - $item"
        done
        error "Please install them and run the script again."
    fi
}

install_apps() {
    BASE_PKGS=(git rsync nano fastfetch greetd greetd-agreety fish fisher github-cli micro jdk-openjdk shfmt otf-monaspace ttf-material-symbols-variable noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra timidity++ mpd mpc rmpc mpdscribble cava brightnessctl flatpak tree beets bash-completion chromaprint ffmpeg gst-plugins-bad gst-plugins-good gst-plugins-ugly gst-libav gst-python imagemagick python-beautifulsoup4 python-discogs-client python-flask python-gobject python-langdetect python-librosa python-mpd2 python-pyacoustid python-pylast python-requests-oauthlib python-xdg python-titlecase)
    DESKTOP_PKGS=(wayland niri xorg xwayland-satellite wl-clipboard fuzzel mako foot polkit-gnome xdg-desktop-portal xdg-desktop-portal-gnome gnome-keyring awww swayidle)
    APP_PKGS=(firefox zed nicotine+ nautilus vesktop gimp steam celluloid loupe fragments obsidian seahorse gaphor solanum)

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
    # mpd doesn't create these itself
    mkdir -p "$HOME/.local/share/mpd/playlists"
    mkdir -p "$HOME/.local/state/mpd"

    local SOURCES=(
        "Pictures/Wallpapers"
        ".config/niri"
        ".config/rmpc"
        ".config/fastfetch"
        ".config/foot"
        ".config/fuzzel"
        ".config/mako"
        ".config/mpd"
        ".config/beets"
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
    local USER_SERVICES=(mpd mpd-discord-rpc mpdscribble)
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
            rsync -av --delete --progress /mnt/Music/ $HOME/Music/
            rsync -av --delete --progress /mnt/Code $HOME/

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

    # find a line that starts with GRUB_CMDLINE_LINUX_DEFAULT, if it has the word "splash", removes that word
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
configure_apps
grub_tweaks
giffoni_related

log "All done. Restart and enjoy."
