#!/bin/bash

UTBIN=/usr/bin
TLCBIN=/usr/lib
LOG="/home/tsuser/pfx.log"

UTOU="ou=uttoken,ou=utdata,o=fsr,dc=de"
UTSD="ou=utsession,ou=utdata,o=fsr,dc=de"

LDAP=ldap.fz-rossendorf.de
LDIF=/tmp/$$.ldif

export LD_LIBRARY_PATH=$UTBIN

RTYPE=$1
PID=$2
HOST=$3
export ETYPE=0

#function finish
#{
#   echo "Interrupting session for $PID ($MPID) with child $CPID" >> $LOG 2>&1
#   $UTBIN/tlckill.sh >> $LOG 2>&1
#   $UTBIN/utupdate.sh 255 $PID >> $LOG 2>&1
#   export ETYPE=2
#}

#--- TRAP handling for clean exit --------------------
export MPID=$$
export CPID=0
trap 'echo "Interrupting session for $PID ($MPID) with child $CPID" >> $LOG 2>&1; $UTBIN/tlckill.sh >> $LOG 2>&1; $UTBIN/utupdate.sh 255 $PID >> $LOG 2>&1; ETYPE=2' SIGINT SIGTERM
#trap finish SIGINT SIGTERM
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
		APP="tlc"
		;;
	    RDP)
		APP="xfreerdp"
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
		STYPE="NX"
		APP="tlc"
		;;
	    1)
		STYPE="RDP"
		APP="xfreerdp"
		;;
	    2)
		STYPE="APP"
		APP="firefox"
		;;
        esac
	echo "new session of type $STYPE for $PID on host $HOST" >> $LOG 2>&1
    fi
else
#    UNAME="kiosk"
#    PID="`nodename -n`"
    PID="`hostname`"
    case $RTYPE in
	0)
	    #STYPE="NX"
	    #for testing ...
	    STYPE="NX"
	    APP="tlc"
	    ;;
	1)
	    STYPE="RDP"
	    APP="xfreerdp"
	    ;;
	2)
	    STYPE="APP"
	    APP="firefox"
	    ;;
esac
echo "new session of type $STYPE for $PID on host $HOST" >> $LOG 2>&1
fi

# execute some command here
echo "EXEC: $STYPE @ $HOST : $APP"# >> $LOG 2>&1

case $STYPE in
    RDP)
	PWDARG=`$UTBIN/utpwd $HOST $UNAME`

        if [ "$?" != "0" ];
        then
	  PWD_UNAME=$(echo $PWDARG | cut -f1 -d~)
	  PWD_PWD=$(echo $PWDARG | cut -f2 -d~)

	  if [ "$PWD_UNAME" != "" ];
	  then
	      xfreerdp /cert-ignore /f /u:"$PWD_UNAME" /p:"$PWD_PWD" /d:FZR /v:$HOST & >> $LOG 2>&1
	  else
	      xfreerdp /cert-ignore /f                               /d:FZR /v:$HOST & >> $LOG 2>&1
	  fi
	  export CPID=$!
	else
	  export CPID=-1
	fi
	;;
    NX)
	if [ "$UNAME" != "" ];
	then
	    UNP="-u $UNAME"
	else
	    UNP=""
	fi
	if [ "$4" != "password" ];
	then
	    echo "TLC:pubkey"
            # enable AUTOLOGIN=1 in config file!
	    $TLCBIN/thinlinc/bin/tlclient -x -h options,controlpanel $UNP -C /etc/tlc-pubkey.cfg $HOST & >> $LOG 2>&1
	    export CPID=$!
	else
	    echo "TLC:password"
	    $TLCBIN/thinlinc/bin/tlclient -x -h options,controlpanel $UNP -C /etc/tlc-password.cfg $HOST & >> $LOG 2>&1
	    export CPID=$!
	fi
        # it looks like login was o.k., remove user key
	;;
    APP)
	$APP & >> $LOG 2>&1
	export CPID=$!
	;;
esac

if [ "$CPID" != "-1" ];
then

    # bad idead, should be based on connection established "signal"
    sleep 15
    rm -f /tmp/user.key

    echo "Childprocess started as $CPID over $MPID" >> $LOG 2>&1

    export RUNNING=0
    while [[ $RUNNING -eq 0 && $ETYPE -eq 0 ]];
    do
       sleep 1
       export RUNNING=`kill -0 $CPID &> /dev/null; echo $?`
#       echo "running: $RUNNING etype=$ETYPE" >> $LOG 2>&1
    done

    echo "exit-type=$ETYPE, running=$RUNNING" >> $LOG 2>&1

    if [ $ETYPE -eq 0 ];
    then
	SDN="cn=$PID,ou=utsession,ou=utdata,o=fsr,dc=de"
	echo "Session $CPID closed, removing $SDN" >> $LOG 2>&1
	ldapdelete -x -y $UTBIN/.pwd -h $LDAP -D "cn=manager,o=fsr,dc=de" $SDN >> $LOG 2>&1
    fi
fi

echo "utrun.sh: exiting" >> $LOG 2>&1
exit 0
