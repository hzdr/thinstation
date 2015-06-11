#!/bin/sh

LOG="${HOME}/pfx.log"

WINID=""

while [ "$WINID" = "" ]; do
    WINID=`xdotool search "ThinLinc Client" 2>&1 | grep -v "Defaulting"`
#    sleep 1
done

sleep 1

echo "Moving mouse to [$WINID] connect button and send click" >> $LOG 2>&1
xdotool mousemove --window $WINID --sync 400 150 >> $LOG 2>&1
xdotool click --window $WINID 1 >> $LOG 2>&1
