#!/bin/sh
xsetroot -solid black

HOSTNAME=$(hostname -s)

if [ -e ~/.Xresources ]; then
    xrdb -load ~/.Xresources &
fi

if [ -e ~/.Xresources.${HOSTNAME} ]; then
    xrdb -load ~/.Xresources.${HOSTNAME} &
fi

if [ -e ~/.xmodmaprc ]; then
    xmodmap ~/.xmodmaprc &
fi

# mouse
xset m 5 10

# bell length and pitch
xset b 100 400 25

# turn displays off after 10 minutes idle
xset s off
xset +dpms
xset dpms 0 600 650

# notifications
if [ -e ~/.dunstrc ]; then
    type dunst > /dev/null && dunst -conf ~/.dunstrc &
fi

exec spectrwm
