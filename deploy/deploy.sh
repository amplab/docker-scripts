#!/bin/bash

BASEDIR=$(cd $(dirname $0); pwd)

spark_images=( "spark:0.7.3" "spark:0.8.0" )
shark_images=( "shark:0.7.0" )

start_shell=0
VOLUME_MAP=""

image_type="?"
image_version="?"
NUM_WORKERS=2

source $BASEDIR/start_nameserver.sh
source $BASEDIR/start_shark_cluster.sh
source $BASEDIR/start_spark_cluster.sh

function check_root() {
    if [[ "$USER" != "root" ]]; then
        echo "please run as: sudo $0"
        exit 1
    fi
}

function print_help() {
    echo "usage: $0 -i <image> [-w <#workers>] [-v <data_directory>] [-c]"
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
    while getopts "i:w:cv:h" opt; do
        case $opt in
        i)
            echo "$OPTARG" | grep "spark:" > /dev/null;
	    if [ "$?" -eq 0 ]; then
                image_type="spark"
            fi
            echo "$OPTARG" | grep "shark:" > /dev/null;
            if [ "$?" -eq 0 ]; then
                image_type="shark"
            fi
	    image_name=$(echo "$OPTARG" | awk -F ":" '{print $1}')
            image_version=$(echo "$OPTARG" | awk -F ":" '{print $2}') 
          ;;
        w)
            NUM_WORKERS=$OPTARG
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
    start_spark_master ${image_name}-master
    sleep 40
    start_spark_workers ${image_name}-worker
    sleep 3
    print_spark_cluster_info ${image_name}-shell
    if [[ "$start_shell" -eq 1 ]]; then
        sudo docker run -i -t -dns $NAMESERVER_IP ${image_name}-shell:$SPARK_VERSION
    fi
elif [ "$image_type" == "shark" ]; then
    SHARK_VERSION=0.7.0
    echo "*** Starting Shark $SHARK_VERSION + Spark ***"
    start_nameserver
    sleep 10
    start_shark_master ${image_name}-master
    sleep 40
    start_shark_workers ${image_name}-worker
    sleep 3
    print_shark_cluster_info ${image_name}-shell
    if [[ "$start_shell" -eq 1 ]]; then
        sudo docker run -i -t ${image_name}-shell:$SHARK_VERSION
    fi
else
    echo "not starting anything"
fi

