#!/bin/bash

DEBUG=0
BASEDIR=$(cd $(dirname $0); pwd)

spark_images=( "amplab/spark:0.9.0")
shark_images=( "amplab/shark:0.8.0" )
NAMESERVER_IMAGE="amplab/dnsmasq-precise"

start_shell=0
VOLUME_MAP=""

image_type="?"
image_version="?"
NUM_WORKERS=2

source $BASEDIR/start_nameserver.sh
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
elif [ "$image_type" == "shark" ]; then
    SHARK_VERSION="$image_version"
    # note: we currently don't have a Shark 0.9 image but it's safe Spark
    # to Shark's version for all but Shark 0.7.0
    if [ "$SHARK_VERSION" == "0.9.0" ] || [ "$SHARK_VERSION" == "0.8.0" ]; then
        SPARK_VERSION="$SHARK_VERSION"
    else
        SPARK_VERSION="0.7.3"
    fi
    echo "*** Starting Shark $SHARK_VERSION + Spark ***"
else
    echo "not starting anything"
    exit 0
fi

start_nameserver $NAMESERVER_IMAGE
wait_for_nameserver
start_master ${image_name}-master $image_version
wait_for_master
if [ "$image_type" == "spark" ]; then
    SHELLCOMMAND="sudo $BASEDIR/start_shell.sh -i ${image_name}-shell:$SPARK_VERSION -n $NAMESERVER $VOLUME_MAP"
elif [ "$image_type" == "shark" ]; then
    SHELLCOMMAND="sudo $BASEDIR/start_shell.sh -i ${image_name}-shell:$SHARK_VERSION -n $NAMESERVER $VOLUME_MAP"
fi

start_workers ${image_name}-worker $image_version
get_num_registered_workers
echo -n "waiting for workers to register "
until [[  "$NUM_REGISTERED_WORKERS" == "$NUM_WORKERS" ]]; do
    echo -n "."
    sleep 1
    get_num_registered_workers
done
echo ""
print_cluster_info "$SHELLCOMMAND"
if [[ "$start_shell" -eq 1 ]]; then
    SHELL_ID=$($SHELLCOMMAND | tail -n 1 | awk '{print $4}')
    sudo docker attach $SHELL_ID
fi
