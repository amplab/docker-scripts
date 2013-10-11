#!/bin/bash

spark_images=( "spark:0.7.3" "spark:0.8.0" )
shark_images=( "shark:0.7.0" )

start_shell=0
VOLUME_MAP=""

image_type="?"
image_version="?"

source start_nameserver.sh
source start_shark_cluster.sh
source start_spark_cluster.sh

function check_root() {
    if [[ "$USER" != "root" ]]; then
        echo "please run as: sudo $0"
        exit 1
    fi
}

function print_help() {
    echo "usage: $0 -i <image> [-v <data_directory>] [-c]"
    echo ""
    echo "  image:    spark or shark image from:"
    echo -n "               "
    for i in ${spark_images[@]}; do
        echo -n "  $i"
    done
    echo ""
    echo -n "               "
    for i in ${shark_images[@]}; do
        echo -n "  $i"
    done
    echo ""
}

function parse_options() {
    while getopts "i:cv:h" opt; do
        case $opt in
        i)
            image_name=$OPTARG
            echo "$image_name" | grep "^spark:" > /dev/null;
	    if [ "$?" -eq 0 ]; then
                image_type="spark"
            fi
            echo "$image_name" | grep "^shark:" > /dev/null;
            if [ "$?" -eq 0 ]; then
                image_type="shark"
            fi
            image_version=$(echo "$image_name" | awk -F ":" '{print $2}')
          ;;
        h)
            print_help
            exit 0
          ;;
        c)
            start_shell=1
          ;;
        v)
            VOLUME_MAP=$OPTARG
          ;;
        esac
    done

    if [ "$image_type" == "?" ]; then
        echo "missing or invalid option: -i <image>"
        exit 1
    fi

    if [ ! "$VOLUME_MAP" == "" ]; then
        echo "data volume chosen: $VOLUME_MAP"
        VOLUME_MAP="-v $VOLUME_MAP:/data"
    fi
}

check_root

if [[ "$#" -eq 0 ]]; then
    print_help
    exit 1
fi

parse_options $@

if [ "$image_type" == "spark" ]; then
    SPARK_VERSION="$image_version"
    echo "*** Starting Spark $SPARK_VERSION ***"
    start_nameserver
    sleep 10
    start_spark_master
    sleep 40
    start_spark_workers
    sleep 3
    print_spark_cluster_info
    if [[ "$start_shell" -eq 1 ]]; then
        sudo docker run -i -t -dns $NAMESERVER_IP spark-shell:$SPARK_VERSION $MASTER_IP
    fi
elif [ "$image_type" == "shark" ]; then
    SHARK_VERSION=0.7.0
    echo "*** Starting Shark $SHARK_VERSION + Spark ***"
    start_nameserver
    sleep 10
    start_shark_master
    sleep 40
    start_shark_workers
    sleep 3
    print_shark_cluster_info
    if [[ "$start_shell" -eq 1 ]]; then
        sudo docker run -i -t shark-shell:$SHARK_VERSION $MASTER_IP
    fi
else
    echo "not starting anything"
fi

