#!/bin/bash

NAMESERVER=-1
NAMESERVER_IP=
DOMAINNAME=
#".mycluster.com"

# starts the dnsmasq nameserver
function start_nameserver() {
    DNSDIR="/tmp/dnsdir_$RANDOM"
    DNSFILE="${DNSDIR}/0hosts"
    mkdir $DNSDIR

    echo "starting nameserver container"
    NAMESERVER=$(sudo docker run -d -h nameserver${DOMAINNAME} -v $DNSDIR:/etc/dnsmasq.d amplab/dnsmasq-precise)
    echo "started nameserver container:  $NAMESERVER"
    echo "DNS host->IP file mapped:      $DNSFILE"
    sleep 2
    NAMESERVER_IP=$(sudo docker logs $NAMESERVER 2>&1 | egrep '^NAMESERVER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
    echo "NAMESERVER_IP:                 $NAMESERVER_IP"
    echo "address=\"/nameserver/$NAMESERVER_IP\"" > $DNSFILE
}

function wait_for_nameserver {
    echo -n "waiting for nameserver to come up "
    # Note: the nameserver resolves its own hostname to 127.0.0.1
    dig nameserver @${NAMESERVER_IP} | grep ANSWER -A1 | grep 127.0.0.1 > /dev/null
    until [ "$?" -eq 0 ]; do
        echo -n "."
        sleep 1
        dig nameserver @${NAMESERVER_IP} | grep ANSWER -A1 | grep 127.0.0.1 > /dev/null;
    done
    echo ""
}
