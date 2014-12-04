#!/bin/sh
#
# a small shell script to create a standard firefox profile, start firefox
# and then upon closing it we cleanup accordingly
#

FIREFOX="/bin/firefox"

# start firefox now
if [ -e "${FIREFOX}" ]; then
  
  ${FIREFOX}

  exit $?
else
  exit 1
fi
