#!/bin/sh

WALLPAPER_LIGHT="$HOME/Pictures/Wallpaper/light"
WALLPAPER_LIGHT_OVERVIEW="$HOME/Pictures/Wallpaper/overview-light"
WALLPAPER_DARK="$HOME/Pictures/Wallpaper/dark"
WALLPAPER_DARK_OVERVIEW="$HOME/Pictures/Wallpaper/overview-dark"

case "$1" in
  dark)  WALLPAPER="$WALLPAPER_DARK" WALLPAPER_OVERVIEW="$WALLPAPER_DARK_OVERVIEW" ;;
  light) WALLPAPER="$WALLPAPER_LIGHT" WALLPAPER_OVERVIEW="$WALLPAPER_LIGHT_OVERVIEW" ;;
  *) exit 1 ;;
esac

awww img $WALLPAPER* -t fade --transition-fps 60 --transition-bezier "0.25,0.46,0.45,0.94"
awww img $WALLPAPER_OVERVIEW* -n=-overview -t fade --transition-fps 60 --transition-bezier "0.25,0.46,0.45,0.94"
