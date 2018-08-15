#!/bin/sh

MODE="$1"
OUT="$HOME/tmp/screenshot-$(date "+%Y-%m-%dT%H:%M:%S%z").png"

if [ "$MODE" = full ]; then
    import -adjoin -screen -window root -silent ${OUT}
elif [ "$MODE" = window ]; then
    active_window=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)" | sed -e "s/.* 0x/0x/")
    import -window "${active_window}" ${OUT}
else
    # interactive selection
    import -silent ${OUT}
fi

