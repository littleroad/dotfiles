#!/usr/bin/env bash

function run {
  if ! pgrep -f $1; then
    $@ &
  fi
}

run "xrandr --output HDMI1 --auto --output DP1 --auto --right-of HDMI1"
run "picom --config /home/luke/.config/compton.conf"
run "light-locker"
run "fcitx5"
run "pidgin"
run "nextcloud"
run "syncthing-gtk"
run "blueman-applet"
run "telegram-desktop"
run "sakura"
run "chromium"
