#!/usr/bin/env bash

function run {
  if ! pgrep -f $1; then
    $@ &
  fi
}

run "picom"
run "light-locker"
run "fcitx5"
run "nextcloud"
run "blueman-applet"
run "Telegram"
run "google-chrome-canary"
