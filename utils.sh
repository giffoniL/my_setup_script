#!/usr/bin/env bash

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
