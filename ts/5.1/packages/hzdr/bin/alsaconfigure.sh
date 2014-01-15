#!/bin/sh

createASoundConf()
{
  local SNDCRD1=$1
  local SNDDEV1=$2
  local SNDCRD2=$3
  local SNDDEV2=$4

  # generate the /etc/asound.conf now
  if [ -z "${SNDCRD2}" ]; then
    cat >$ROOT/etc/asound.conf << EOL
pcm.!default {
    type hw
    card ${SNDCRD1}
    device ${SNDDEV1}
}
ctl.!default {
    type hw           
    card ${SNDCRD1}
    device ${SNDDEV1}
}
EOL
  else
    cat >$ROOT/etc/asound.conf << EOL
pcm.!default {
  type route;
  slave.pcm {
      type multi;
      slaves.a.pcm "dev0";
      slaves.b.pcm "dev1";
      slaves.a.channels 2;
      slaves.b.channels 2;
      bindings.0.slave a;
      bindings.0.channel 0;
      bindings.1.slave a;
      bindings.1.channel 1;

      bindings.2.slave b;
      bindings.2.channel 0;
      bindings.3.slave b;
      bindings.3.channel 1;
  }

  ttable.0.0 1;
  ttable.1.1 1;
  ttable.0.2 1;
  ttable.1.3 1;
}

ctl.!default {
  type hw
  card ${SNDCRD1}
  device ${SNDDEV1}
}

pcm.dev0 {
   type dmix
   ipc_key 1024
   slave {
       pcm "hw:${SNDCRD1},${SNDDEV1}"
       period_time 0
       period_size 2048
       buffer_size 65536
       buffer_time 0
       periods 128
       rate 48000
       channels 2
    }
    bindings {
       0 0
       1 1
    }
}

pcm.dev1 {
   type dmix
   ipc_key 2048
   slave {
       pcm "hw:${SNDCRD2},${SNDDEV2}"
       period_time 0
       period_size 2048
       buffer_size 65536
       buffer_time 0
       periods 128
       rate 48000
       channels 2
    }
    bindings {
       0 0
       1 1
    }
}

ctl.dev0 {
   type hw
   card ${SNDCRD1}
   device ${SNDDEV1}
}

ctl.dev1 {
   type hw
   card ${SNDCRD2}
   device ${SNDDEV2}
}
EOL
  fi
}


# First we check if headphones are plugged-in if not 
# we check if USB sound is plugged in
# Otherwise setting HDMI 0 as default or even if there is no HDMI
# we use the first card listed by aplay

CTRLWORD="off"                             
if [ -n "`aplay -l | grep Analog`" ] ; then              
  APLAYOUT=`aplay -l | grep Analog | head -1 | tr -d ':'`            
  SNDCRD=`echo $APLAYOUT | sed -rn 's/.*card //p' | awk '{print $1}'`  
  SNDDEV=`echo $APLAYOUT | sed -rn 's/.*device //p' | awk '{print $1}'`
  #now we gonna check if headphones are plugged                                       
  CTRLLINE=`amixer -c $SNDCRD contents | grep -A 2 "Headphone Jack" | grep " values="`
  CTRLWORD=`echo $CTRLLINE | awk '{split($0,a,"="); print a[2]}'`
  CTRLWORD=`echo ${CTRLWORD//[[:blank:]]/}`
  if [ -n $CTRLWORD ] ; then            
    if [ $CTRLWORD = "on" ] ; then
      createASoundConf ${SNDCRD} ${SNDDEV}
			amixer -c ${SNDCRD} sset Master 100 unmute
    fi                                    
  else            
    CTRLWORD="off"   
  fi                    
fi              
if [ $CTRLWORD = "off" ]; then
  if [ -n "`aplay -l | grep USB`" ] ; then
    APLAYOUT=`aplay -l | grep USB | head -1 | tr -d ':'`
    SNDCRD=`echo $APLAYOUT | sed -rn 's/.*card //p' | awk '{print $1}'`
    SNDDEV=`echo $APLAYOUT | sed -rn 's/.*device //p' | awk '{print $1}'`
    createASoundConf ${SNDCRD} ${SNDDEV}                                 
  else                                                                   
    if [ -n "`aplay -l | grep HDMI`" ]; then                             
      APLAYOUT=`aplay -l | grep HDMI | head -1 | tr -d ':'`
      SNDCRD1=`echo $APLAYOUT | awk '{print $3}'`          
      SNDDEV1=`echo $APLAYOUT | sed -rn 's/.*device //p' | awk '{print $1}'`
      if [ `aplay -l | grep HDMI | wc -l` -gt 1 ]; then                     
        APLAYOUT=`aplay -l | grep HDMI | tail -1 | tr -d ':'`               
        SNDCRD2=`echo $APLAYOUT | awk '{print $3}'`                         
        SNDDEV2=`echo $APLAYOUT | sed -rn 's/.*device //p' | awk '{print $1}'`
      fi                                                                      
      #createASoundConf ${SNDCRD1} ${SNDDEV1} ${SNDCRD2} ${SNDDEV2}           
      createASoundConf ${SNDCRD1} ${SNDDEV1}                                  
    else                                                           
      APLAYOUT=`aplay -l | grep card | head -1 | tr -d ':'`        
      SNDCRD=`echo $APLAYOUT | awk '{print $3}'`           
      SNDDEV=`echo $APLAYOUT | sed -rn 's/.*device //p' | awk '{print $1}'`
      createASoundConf ${SNDCRD} ${SNDDEV}                                 
    fi                                                                     
  fi                                                                       
fi                                        
