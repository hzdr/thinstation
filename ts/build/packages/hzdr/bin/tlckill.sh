#!/bin/sh

kill -9 `ps ax | grep "tlclient" | grep -v grep | awk '{ print $1; }'`
