#!/bin/bash

# this is a personal script for backuping my current set of personal files into my HD
# stuff like pictures, books, music, etc etc. stuff that i can't just publicly host

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

while true; do
    read -p "Are you Giffoni, and is your external hard drive plugged in? (y/n): " yn
    case $yn in
    [Yy]*)

        log "Mounting external hard drive..."
        sudo mount /dev/sda1 /mnt

        log "Backuping files into external hard drive..."
        rsync -rtv --delete --progress $HOME/.mpdscribble /mnt/
        rsync -rtv --delete --progress $HOME/Music /mnt/
        rsync -rtv --delete --progress $HOME/Code /mnt/

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
