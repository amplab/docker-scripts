#!/bin/bash

if [[ "$USER" != "root" ]]; then
    echo "please run as: sudo $0"
    exit 1
fi

CURDIR=$(pwd)
BASEDIR=$(cd $(dirname $0); pwd)"/.."
dir_list=( "dnsmasq-precise" "apache-hadoop-hdfs-precise" "spark" "shark" "spark-0.8" )

IMAGE_PREFIX=""
#"/amplab"

# NOTE: the order matters but this is the right one
for i in ${dir_list[@]}; do
	echo building $i;
	cd ${BASEDIR}/$i
        cat build
        ./build
done
cd $CURDIR
