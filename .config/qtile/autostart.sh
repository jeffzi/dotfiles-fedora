#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

xrandr --output HDMI-0 --auto --output DP-0 --auto --primary --right-of HDMI-0
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run picom --experimental-backends
run feh --bg-center ~/.config/wallpapers/astronaut_jellyfish.jpg
run dunst -config ~/.config/dunst/dunstrc
run copyq
run flameshot
run blueman-applet