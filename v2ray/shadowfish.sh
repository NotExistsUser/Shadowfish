#!/bin/sh
export PATH=/sbin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/nemo/bin
SERVER=$(su nemo -c '/usr/bin/dconf read /apps/jolla-settings-v2ray/serverIP'|sed $'s/\'//g')
LOCALPORT=12345

if [ "$1" = "startProxy" ] ;then
    /sbin/iptables -t nat -F # V2RAY
    /sbin/iptables -t nat -X # V2RAY
    ulimit -n 51200
    
    if [ -z "$SERVER" ]; then
        exit 1;
    fi
    
    SERVERIPS=$(/usr/bin/nslookup $SERVER|grep Address|grep -v "#"|awk '{print $2}')
    if [ -z "$SERVERIPS" ]; then
        SERVERIPS=$(ping -c 1 $SERVER | gawk -F'[()]' '/PING/{print $2}')
        if [ -z "$SERVERIPS" ]; then
            echo "can't resolve $SERVER ip"
            exit 1;
        fi
    fi
    systemctl status myv2ray.service 2>&1 >> /dev/null
    if [ "$?" -ne "0" ]; then
        echo "start v2ray failed"
        exit 1;
    fi
    /sbin/iptables -t nat -N V2RAY
    for SERVERIP in ${SERVERIPS}; do
        /sbin/iptables -t nat -A V2RAY -d $SERVERIP -j RETURN
    done
    /sbin/iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 172.16.0.0/12 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN
    /sbin/iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN
    /sbin/iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff
    /sbin/iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports $LOCALPORT
    /sbin/iptables -t nat -A OUTPUT -p tcp -j V2RAY
    /sbin/iptables -t nat -A PREROUTING  -p tcp -j V2RAY
    exit 0;
elif [ "$1" = "stopProxy" ]; then
    /sbin/iptables -t nat -F # V2RAY
    /sbin/iptables -t nat -X # V2RAY
    exit 0;
elif [ "$1" = "startSvc" ]; then
    systemctl start myv2ray.service
    exit $?;
elif [ "$1" = "stopSvc" ]; then
    systemctl stop myv2ray.service
    exit $?;
else
    exit 1;
fi