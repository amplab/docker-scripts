#!/bin/bash

NAMESERVER=-1
NAMESERVER_IP=

# starts the dnsmasq nameserver
function start_nameserver() {
    rm -rf /tmp/dnsdir
    mkdir /tmp/dnsdir

    echo "starting nameserver container"
    NAMESERVER=$(sudo docker run -d -h nameserver -v /tmp/dnsdir:/etc/dnsmasq.d dnsmasq-precise)
    echo "started nameserver container:  $NAMESERVER"
    sleep 3
    NAMESERVER_IP=$(sudo docker logs $NAMESERVER 2>&1 | egrep '^NAMESERVER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
    echo "NAMESERVER_IP:                 $NAMESERVER_IP"
    echo "address=\"/nameserver/$NAMESERVER_IP\"" > /tmp/dnsdir/0hosts
}
