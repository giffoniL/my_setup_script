#!/bin/sh

case "$1" in
  dark)
    sed -i '
      1s/.*/# DARK-MODE/
      s/^background=.*/background=343437FF/
      s/^match=.*/match=81D0FFFF/
      s/^selection=.*/selection=FFFFFF08/
      s/^selection-match=.*/selection-match=81D0FFFF/
    ' ~/.config/fuzzel/fuzzel.ini
    ;;
  light)
    sed -i '
      1s/.*/# LIGHT-MODE/
      s/^background=.*/background=48484CFF/
      s/^match=.*/match=81D0FFFF/
      s/^selection=.*/selection=FFFFFF08/
      s/^selection-match=.*/selection-match=81D0FFFF/
    ' ~/.config/fuzzel/fuzzel.ini
    ;;
  default) exit 1;;
esac



