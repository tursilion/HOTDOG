#!/bin/bash

if [ "x$HOTDOG_MODE" = "xamiga" ]; then
    xterm -cm -bg '#0055aa' -fg white -cr '#ff8800' +bc +uc
elif [ "x$HOTDOG_MODE" = "xhotdogstand" ]; then
    xterm -bg '#0055aa' -fg white -cr '#ffff00' +bc +uc
elif [ "x$HOTDOG_MODE" = "xaqua" ]; then
    xterm -bg black -fg white -cr '#ffff00' +bc +uc
else
    xterm -bg white -fg black +bc +uc
fi
#    xterm -geometry 80x50 +bc +uc

