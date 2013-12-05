#!/bin/bash

function kill_containers() {
    containers=($1)
    for i in "${containers[@]}"; do
        echo "killing container $i"
        sudo docker kill "$i"
    done
}

if [ "$#" -ne "1" ]; then
    echo -e "usage:\n   $0 spark\n   $0 shark\n   $0 mesos\n   $0 nameserver"
    exit 1;
fi

if [[ "$USER" != "root" ]]; then
   echo "please run as: sudo $0"
   exit 1
fi

clustertype=$1

if [[ "$clustertype" == "nameserver" ]]; then
    nameserver=$(sudo docker ps | grep dnsmasq_files | awk '{print $1}' | tr '\n' ' ')
    kill_containers "$nameserver"
else
    master=$(sudo docker ps | grep ${clustertype}_master | awk '{print $1}' | tr '\n' ' ')
    workers=$(sudo docker ps | grep ${clustertype}_worker | awk '{print $1}' | tr '\n' ' ')
    shells=$(sudo docker ps | grep ${clustertype}_shell | awk '{print $1}' | tr '\n' ' ')
    kill_containers "$master"
    kill_containers "$workers" 
    kill_containers "$shells"
fi

