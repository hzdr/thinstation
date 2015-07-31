#!/bin/sh

kill -9 `ps ax | grep "tlclient" | grep -v grep | awk '{ print $1; }'` >> /home/tsuser/chooser.log 2>&1
killall xfreerdp >> /home/tsuser/chooser.log 2>&1
