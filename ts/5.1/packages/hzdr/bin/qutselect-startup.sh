#!/bin/sh

has_ewmh_wm()
{
    local name
    local id
    local child_id

    # If property does not exist, "id" will contain "no such atom on any window"
    id=`xprop -root 32x ' $0\n' _NET_SUPPORTING_WM_CHECK | awk '{ print $2 }'`
    child_id=`xprop -id "${id}" 32x ' $0\n' _NET_SUPPORTING_WM_CHECK 2>/dev/null | awk '{ print $2 }'`

    if [ "${id}" != "${child_id}" ]; then
        return 1
    fi

    return 0
}

wait_for_wm()
{
    for i in `seq 30`; do
        if has_ewmh_wm; then
            return 0
        fi

        sleep 1
    done
    return 1
}

# Clean up after earlier WMs
xprop -root -remove _NET_NUMBER_OF_DESKTOPS \
      -remove _NET_DESKTOP_NAMES \
      -remove _NET_CURRENT_DESKTOP 2> /dev/null

# start openbox wm
openbox --config-file /etc/xdg/openbox/rc-single-app.xml &

# start the pulseaudio daemon to make sure we have sound
/usr/bin/pulseaudio --start --log-target=syslog --disallow-exit

# wait for openbox to start
if ! wait_for_wm; then
    echo "$0: Timeout waiting for openbox to start"
fi

# start qutselect unlimited
while true; do
  qutselect -dtlogin -nouser -keep
  if [ $? -ne 0 ]; then
    break 
  fi
done

# stop openbox again
openbox --exit
