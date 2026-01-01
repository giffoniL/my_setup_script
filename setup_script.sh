#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/giffoni"

log() {
	echo -e "${GREEN}[INFO] $1${NC}"
}

warn() {
	echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
	echo -e "${RED}[ERROR] $1${NC}"
	exit 1
}

check_deps() {

	local missing=()

	for bin in "$@"; do
		if ! command -v "$bin" >/dev/null 2>&1; then
			missing+=("$bin")
		fi
	done

	if [ ${#missing[@]} -ne 0 ]; then
		warn "FATAL: The following dependencies are missing:"
		for item in "${missing[@]}"; do
			warn "  - $item"
		done
		error "Please install them and run the script again."
	fi
}

install_apps() {

	BASE_PKGS=(micro jdk-openjdk otf-monaspace noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra timidity++ mpd ncmpcpp brightnessctl python python-pipx flatpak tree)
	DESKTOP_PKGS=(wayland niri xorg xwayland-satellite fuzzel mako swaybg foot)
	APP_PKGS=(firefox zed nicotine+ vesktop-bin waydroid steam celluloid loupe fragments errands iotas)
	ALL_PACMAN_PKGS=("${BASE_PKGS[@]}" "${DESKTOP_PKGS[@]}" "${APP_PKGS[@]}")
	PARU_PKGS=(mpd-discord-rpc apple_cursor)

	log "Installing packages..."
	sudo pacman -Syu --needed "${ALL_PACMAN_PKGS[@]}"
	paru -S --needed "${PARU_PKGS[@]}"

	log "Installing beets through pipx..."
	pipx install "beets[fetchart,embedart,lastgenre,scrub,replaygain,thumbnails,info]"
	pipx ensurepath

	log "Installing Reversal-Blue icon theme..."
	git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git /tmp/reversal-icons
	/tmp/reversal-icons/install.sh -t blue
	rm -rf /tmp/reversal-icons

	log "Finished installing apps."

}

configure_apps() {

	log "Making MPD's log file that it doesn't make by itself for some reason..."
	mkdir -p "$HOME/.local/state/mpd/"
	touch "$HOME/.local/state/mpd/log"

	declare -A FILES=(
		["$SOURCE_DIR/Pictures/Wallpaper/wallpaper.jpg"]="$HOME/Pictures/Wallpaper/wallpaper.jpg"
		["$SOURCE_DIR/.ncmpcpp/config"]="$HOME/.ncmpcpp/config"
		["$SOURCE_DIR/.config/foot/foot.ini"]="$HOME/.config/foot/foot.ini"
		["$SOURCE_DIR/.config/fuzzel/fuzzel.ini"]="$HOME/.config/fuzzel/fuzzel.ini"
		["$SOURCE_DIR/.config/mako/config"]="$HOME/.config/mako/config"
		["$SOURCE_DIR/.config/mimeapps.list"]="$HOME/.config/mimeapps.list"
		["$SOURCE_DIR/.config/mpd/mpd.conf"]="$HOME/.config/mpd/mpd.conf"
		["$SOURCE_DIR/.config/niri/config.kdl"]="$HOME/.config/niri/config.kdl"
	)

	log "Setting up dotfiles..."
	for src in "${!FILES[@]}"; do
		dest="${FILES[$src]}"
		dest_dir=$(dirname "$dest")

		mkdir -p "$dest_dir"
		install -D "$src" "$dest"
		log "Installed: $dest"
	done

	
	log "Enabling services..."
	if systemctl --user list-units >/dev/null 2>&1; then
		systemctl --user enable --now mako || warn "Failed to enable mako"
		systemctl --user enable --now mpd || warn "Failed to enable mpd"
		systemctl --user enable --now mpd-discord-rpc || warn "Failed to enable mpd-discord-rpc"
	fi

    log "Configuring git..."
	git config --global color.ui auto
	git config --global user.name "Giffoni Lopes"
	git config --global user.email "kgiffoni_@tuta.com"

	log "Finished configuring apps."

}

edit_grub() {

    log "Editing grub..."
    
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
  ' /etc/default/grub | sudo tee /etc/default/grub >/dev/null

	sudo grub-mkconfig -o /boot/grub/grub.cfg

	log "Finished editing grub."
}

sudo -v
check_deps pacman paru git awk sudo
install_apps
configure_apps
edit_grub

log "All done. Restart and enjoy."
