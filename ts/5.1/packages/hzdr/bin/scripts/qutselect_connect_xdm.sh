#!/bin/bash
#
# This is a startup script for qutselect which initates a
# RDP session to a windows server either via rdesktop or uttsc
#
# It receives the following inputs:
#
# $1 = PID of qutselect
# $2 = serverType (SRSS, RDP, VNC)
# $3 = 'true' if dtlogin mode was on while qutselect was running
# $4 = the resolution (either 'fullscreen' or 'WxH')
# $5 = the selected color depth (8, 16, 24)
# $6 = the current max. color depth (8, 16, 24)
# $7 = the selected keylayout (e.g. 'de' or 'en')
# $8 = the domain (e.g. 'FZR', used for RDP)
# $9 = the username
# $10 = the servername (hostname) to connect to

if [ `uname -s` = "SunOS" ]; then
   XEPHYR=/usr/X11/bin/Xephyr
else
   XEPHYR=/usr/bin/Xephyr
fi

#####################################################
# check that we have 8 command-line options at hand
if [ $# -lt 10 ]; then
   printf "ERROR: missing arguments!"
   exit 2
fi

# catch all arguments is some local variables
parentPID="${1}"
serverType="${2}"
dtlogin="${3}"
resolution="${4}"
colorDepth="${5}"
curDepth="${6}"
keyLayout="${7}"
domain="${8}"
username="${9}"
serverName="${10}"

# read the password from stdin
read password

cmdArgs=""

# add -fullscreen if this is a dtlogin or fullscreen session
if [ "x${resolution}" = "xfullscreen" ] || [ "x${dtlogin}" = "xtrue" ]; then
   cmdArgs="$cmdArgs -fullscreen -screen 1024x768x${colorDepth}"
else
   cmdArgs="$cmdArgs -screen ${resolution}x${colorDepth}"
fi

# add the once option to terminate after one session
cmdArgs="$cmdArgs -once"

# enable xinerama extension
cmdArgs="$cmdArgs +xinerama"

# enable xkb extension
cmdArgs="$cmdArgs +kb"
   
# add the server query
cmdArgs="$cmdArgs -query ${serverName}"

if [ "x${dtlogin}" != "xtrue" ]; then
   echo ${XEPHYR} :1 ${cmdArgs}
fi

# run the command
${XEPHYR} :1 ${cmdArgs} &>/dev/null &
if [ $? != 0 ]; then
   printf "ERROR: ${XEPHYR} returned invalid return code"
   exit 2
fi

exit 0
