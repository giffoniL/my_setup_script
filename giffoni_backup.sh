#!/bin/bash

# this is a personal script for backuping my current set of personal files into my HD
# stuff like pictures, books, music, etc etc. stuff that i can't just publicly host

source "utils.sh"

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
