#!/bin/bash

NAMESERVER=-1
NAMESERVER_IP=

# starts the dnsmasq nameserver
function start_nameserver() {
    DNSDIR="/tmp/dnsdir_$RANDOM"
    DNSFILE="${DNSDIR}/0hosts"
    mkdir $DNSDIR

    echo "starting nameserver container"
    if [ "$DEBUG" -gt 0 ]; then
        echo sudo docker run -d -h nameserver -v $DNSDIR:/etc/dnsmasq.d dnsmasq-precise
    fi
    NAMESERVER=$(sudo docker run -d -h nameserver -v $DNSDIR:/etc/dnsmasq.d dnsmasq-precise)
    echo "started nameserver container:  $NAMESERVER"
    echo "DNS host->IP file mapped:      $DNSFILE"
    sleep 3
    NAMESERVER_IP=$(sudo docker logs $NAMESERVER 2>&1 | egrep '^NAMESERVER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
    echo "NAMESERVER_IP:                 $NAMESERVER_IP"
    echo "address=\"/nameserver/$NAMESERVER_IP\"" > $DNSFILE
}
