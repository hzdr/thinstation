#!/bin/bash
#
# This script will be run by acpi and udev and will set the correct audio output
# depending on which audio outputs are currently available.
#
# First we check if headphones are plugged-in if not
# we check if USB sound is plugged in
# Otherwise setting HDMI as default or even if there is no HDMI
# we use the first card listed

getSinkName()
{
  pattern="${1}"

  # now iterate through all sinks and grab its information
  numsinks=$(pactl list short sinks | awk '{ print $1 }')
  for i in ${numsinks}; do
    sinkinfo=`echo "${painfo}" | sed -n "/^Sink #${i}$/,/Formats:/p"`
    searchres=`echo "${sinkinfo}" | grep -e ${pattern}`
    if [ -n "${searchres}" ]; then
      # output the sink name
      echo "${painfo}" | sed -n "/^Sink #${i}$/,/Formats:/p" | grep "Name: " | awk '{ print $2 }'
      break
    fi
  done
}

# get all information pactl list can provide us about our sinks
painfo=$(pactl list sinks)

sinkname=""
# check for the headphones first
if [ -n "`echo \"${painfo}\" | grep -e Headphones.*priority | grep -v 'not available'`" ]; then
  # headphones are plugged in and available, lets find out the sink name
  sinkname=`getSinkName "Headphones.*priority"`

  # make sure the headphones are set to 100% volume
  pactl set-sink-volume ${sinkname} 100%

else
  # check for USB sound devices (Speakers)
  if [ -n "`echo \"${painfo}\" | grep -e Speakers.*priority | grep -v 'not available'`" ]; then
    sinkname=`getSinkName "Speakers.*priority"`
  else
    # check for HDMI devices
    if [ -n "`echo \"${painfo}\" | grep -e HDMI.*priority`" ]; then
      sinkname=`getSinkName "HDMI.*priority"`
    fi
  fi
fi

# check if we have the name of the sink
if [ -n "${sinkname}" ]; then

  # move the null stream input (0) to the new sink
  pactl move-sink-input 0 "${sinkname}"

  # make sure that the new sink is unmuted
  pactl set-sink-mute ${sinkname} 0

else
  echo "WARNING: no available output sink found"
  exit 2
fi

exit 0
