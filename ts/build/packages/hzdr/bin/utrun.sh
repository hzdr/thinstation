#!/bin/sh

UTBIN=/usr/bin
LOG="${HOME}/pfx.log"

UTOU="ou=uttoken,ou=utdata,o=fsr,dc=de"
UTSD="ou=utsession,ou=utdata,o=fsr,dc=de"

LDAP=ldap.fz-rossendorf.de
LDIF=/tmp/$$.ldif

#export LD_LIBRARY_PATH=$UTBIN

RTYPE=$1
PID=$2
ETYPE=0

#--- TRAP handling for clean exit --------------------
MPID=$$
CPID=0
#trap 'echo "Interrupting session for $PID ($MPID) with child $CPID" >> $LOG 2>&1; $UTBIN/tlckill.sh >> $LOG 2&>1; jobs -l >> $LOG 2>&1; kill -9 $CPID >> $LOG 2>&1; exit 0' INT TERM
trap 'echo "Interrupting session for $PID ($MPID) with child $CPID" >> $LOG 2>&1; $UTBIN/tlckill.sh >> $LOG 2&>1; $UTBIN/utupdate.sh 255 $PID >> $LOG 2>&1; ETYPE=1' INT TERM
#-----------------------------------------------------

if [ "$PID" != "" ];
then
    UNAME=`ldapsearch -x -h $LDAP -b $UTOU -LLL "(cn=$PID)" uid | grep uid | awk '{ print $2; }'`
    echo "Payflex.$PID, $UNAME" >> $LOG 2>&1

    # check for existing session
    ldapsearch -x -h $LDAP -b $UTSD -LLL "(cn=$PID)" > $LDIF
    grep "cn: $PID" $LDIF >> $LOG 2>&1
    GR=$?
    
    if [ $GR = 0 ] && [ "$RTYPE" = "reconnect" ];
    then
        HOST=`grep radiusLoginIPHost $LDIF | awk '{ print $2; }'`
        STYPE=`grep radiusServiceType $LDIF | awk '{ print $2; }'`
        case $STYPE in
            NX) 
                APP="xterm -fn 10x20"
                HOST="lts1"
                ;;
            RDP) 
                APP="rdesktop"
                ;;
            APP) 
                APP="firefox"
                ;;
        esac
        echo "Session of type $STYPE for Payflex.$PID exists on host $HOST" >> $LOG 2>&1
        $UTBIN/utupdate.sh $RTYPE $PID $HOST >> $LOG 2>&1
    else
        case $RTYPE in
            0) 
                HOST="lts1"
                STYPE="NX"
                APP="nx"
                ;;
            1) 
                HOST="xats"
                STYPE="RDP"
                APP="rdesktop"
                ;;
            2) 
                HOST="$HOSTNAME"
                STYPE="APP"
                APP="firefox"
                ;;
        esac
        echo "new session of type $STYPE for $PID on host $HOST" >> $LOG 2>&1
    fi
else
    UNAME="kiosk"
    PID="`nodename -n`"
    case $RTYPE in
        0) 
            HOST="lts1"
            #           STYPE="NX"
            # for testing ...
            STYPE="NX"
            APP="nx"
            ;;
        1) 
            HOST="xats"
            STYPE="RDP"
            APP="rdesktop"
            ;;
        2) 
            HOST="$HOSTNAME"
            STYPE="APP"
            APP="firefox"
            ;;
    esac
    echo "new session of type $STYPE for $PID on host $HOST" >> $LOG 2>&1
fi

# execute some command here
echo "EXEC: $STYPE @ $HOST : $APP" >> $LOG 2>&1

case $STYPE in
    RDP)
        if [ "$UNAME" != "" ];
        then
           UNP = "/u:$UNAME"
        else
           UNP = ""
        fi
        xfreerdp /f /multimon /kbd:German /d:FZR $UNP /t:${UNAME}:${HOST} /cert-ignore /drive:USB /mnt/$(hostname)/ /sound:latency:400 /microphone:sys:pulse +fonts +window-drag -menu-anims -themes +wallpaper -toggle-fullscreen /v:${HOST} & >> $LOG 2>&1
        CPID=$!
        echo $CPID > /tmp/ut.pid
        ;;
    NX)
        if [ "$UNAME" != "" ];
        then
            UNP="-u $UNAME"
        else
            UNP=""
        fi
        if [ "$3" != "password" ];
        then
            echo "TLC:pubkey"
            # enable AUTOLOGIN=1 in config file!
            /usr/lib/thinlinc/bin/tlclient -C /etc/tlc-pubkey.cfg -x -h options,controlpanel -u $UNAME $HOST & >> $LOG 2>&1
        else
            echo "TLC:password"
            /usr/lib/thinlinc/bin/tlclient -C /etc/tlc-password.cfg -x -h options,controlpanel -u $UNAME $HOST & >> $LOG 2>&1
        fi 
        CPID=$!
        sleep 1 
        ps | grep -v grep | grep tlclient.bin | awk '{ print $1; }' > /tmp/ut.pid
        ;;
    APP)
#       $UTBIN/apprun.sh "$APP" "$UNAME" "$HOST" "$PID" & >> $LOG
        $APP & >> $LOG 2>&1
        CPID=$!
        echo $CPID > /tmp/ut.pid
        ;;
esac

sleep 5
rm -f /tmp/user.key
CPID=`cat /tmp/ut.pid`
ps >> $LOG 2>&1
echo "Childprocess started as $CPID over $MPID" >> $LOG 2>&1
while [ "`ps ax | grep $CPID | grep -v grep > /dev/null; echo $?`" = "0" ]; do
    sleep 1
done

echo "exit type=$ETYPE" >> $LOG 2>&1

if [ "$ETYPE" = "0" ];
then 
  SDN="cn=$PID,ou=utsession,ou=utdata,o=fsr,dc=de"
  echo "Session $CPID closed, removing $SDN" >> $LOG 2>&1
  ldapdelete -x -y $UTBIN/.pwd -h $LDAP -D "cn=manager,o=fsr,dc=de" $SDN >> $LOG 2>&1
fi

exit 0

