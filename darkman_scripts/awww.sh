#!/bin/sh

WALLPAPERS_DIR="$HOME/Pictures/Wallpapers/"
WALLPAPER_LIGHT="$WALLPAPERS_DIR/light"
WALLPAPER_LIGHT_OVERVIEW="$WALLPAPERS_DIR/overview-light"
WALLPAPER_DARK="$WALLPAPERS_DIR/dark"
WALLPAPER_DARK_OVERVIEW="$WALLPAPERS_DIR/overview-dark"

case "$1" in
  dark)  WALLPAPER="$WALLPAPER_DARK" WALLPAPER_OVERVIEW="$WALLPAPER_DARK_OVERVIEW" ;;
  light) WALLPAPER="$WALLPAPER_LIGHT" WALLPAPER_OVERVIEW="$WALLPAPER_LIGHT_OVERVIEW" ;;
  *) exit 1 ;;
esac

awww img $WALLPAPER* -t fade --transition-fps 60 --transition-bezier "0.25,0.46,0.45,0.94"
awww img $WALLPAPER_OVERVIEW* -n=-overview -t fade --transition-fps 60 --transition-bezier "0.25,0.46,0.45,0.94"
