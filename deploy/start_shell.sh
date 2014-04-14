#!/bin/bash

BASEDIR=$(cd $(dirname $0); pwd)
source $BASEDIR/start_nameserver.sh

SHELL_ID=-1
SHELL_IP=
NAMESERVER_IP=
NAMESERVER_DIR=
NAMESERVER_ID=-1

image_type="?"

DEBUG=1

# TODO: remove redundant image list definition (source from file common to deploy.sh)
spark_shell_images=( "amplab/spark-shell:0.9.0" )
shark_shell_images=( "amplab/shark-shell:0.8.0" )

# TODO: unify with deploy.sh
function check_root() {
    if [[ "$USER" != "root" ]]; then
        echo "please run as: sudo $0"
        exit 1
    fi
}

function print_help() {
    echo "usage: $0 -i <image> -n <nameserver_container> [-v <data_directory>]"
    echo ""
    echo "  image:    spark or shark image from:"
    echo -n "               "
    for i in ${spark_shell_images[@]}; do
        echo -n "  $i"
    done
    echo ""
    echo -n "               "
    for i in ${shark_shell_images[@]}; do
        echo -n "  $i"
    done
    echo ""
}

function parse_options() {
    while getopts "i:n:v:h" opt; do
        case $opt in
        i)
            echo "$OPTARG" | grep "spark-shell:" > /dev/null;
            if [ "$?" -eq 0 ]; then
                image_type="spark"
            fi
            echo "$OPTARG" | grep "shark-shell:" > /dev/null;
            if [ "$?" -eq 0 ]; then
                image_type="shark"
            fi
            image_name=$(echo "$OPTARG" | awk -F ":" '{print $1}')
            image_version=$(echo "$OPTARG" | awk -F ":" '{print $2}') 
          ;;
        h)
            print_help
            exit 0
          ;;
        v)
            VOLUME_MAP=$OPTARG
          ;;
        n)
            NAMESERVER_ID=$OPTARG
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

# TODO: generalize and refactor this with the code for updating
# master and worker nameserver entries.
function set_nameserver_data() {
    IMAGENAME="$image_name:$image_version"
    DNSDIR=$(sudo docker inspect $NAMESERVER_ID | \
        grep dnsdir | awk '{print $2}' | tr -d '":')
    DNSFILE="${DNSDIR}/0hosts"
    SHELL_IP=$(docker inspect $SHELL_ID | \
        grep IPAddress | awk '{print $2}' | tr -d '":,')

    if [ "$DEBUG" -gt 0 ]; then
        echo "NAMESERVER_IP:                 $NAMESERVER_IP"
        echo "DNSFILE:                       $DNSFILE"
        echo "SHELL_IP:                      $SHELL_IP"
        echo "SHELL_HOSTNAME:                $SHELL_HOSTNAME"
    fi

    echo "address=\"/$SHELL_HOSTNAME/$SHELL_IP\"" | sudo tee -a $DNSFILE > /dev/null
}

# starts the spark/shark shell container
function start_shell() {
    IMAGENAME="$image_name:$image_version"
    NAMESERVER_IP=$(docker inspect $NAMESERVER_ID | \
        grep IPAddress | awk '{print $2}' | tr -d '":,')

    if [ "$NAMESERVER_IP" = "" ]; then
        echo "error: cannot determine nameserver IP"
        exit 1
    fi

    #MASTER_IP=$(dig master @$NAMESERVER_IP | grep ANSWER -A1 | \
    #    tail -n 1 | awk '{print $5}')
    resolve_hostname MASTER_IP master

    if [ "$MASTER_IP" = "" ]; then
        echo "error: cannot determine master IP"
        exit 1
    fi

    SHELL_HOSTNAME="shell$RANDOM"
    echo "starting shell container"
    if [ "$DEBUG" -gt 0 ]; then
        echo sudo docker run -i -t -d --dns $NAMESERVER_IP -h $SHELL_HOSTNAME $VOLUME_MAP $IMAGENAME $MASTER_IP
    fi
    SHELL_ID=$(sudo docker run -i -t -d --dns $NAMESERVER_IP -h $SHELL_HOSTNAME $VOLUME_MAP $IMAGENAME $MASTER_IP)

    if [ "$SHELL_ID" = "" ]; then
        echo "error: could not start shell container from image $IMAGENAME"
        exit 1
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
    echo "*** Starting Spark $SPARK_VERSION Shell ***"
elif [ "$image_type" == "shark" ]; then
    SHARK_VERSION="$image_version"
    # note: we currently don't have a Shark 0.9 image but it's safe Spark
    # to Shark's version for all but Shark 0.7.0
    if [ "$SHARK_VERSION" == "0.9.0" ] || [ "$SHARK_VERSION" == "0.8.0" ]; then
        SPARK_VERSION="$SHARK_VERSION"
    else
        SPARK_VERSION="0.7.3"
    fi
    echo "*** Starting Shark $SHARK_VERSION + Spark Shell ***"
else
    echo "not starting anything"
    exit 0
fi

start_shell

sleep 2

set_nameserver_data

echo -n "waiting for nameserver to find shell "
SHELL_IP=$(docker inspect $SHELL_ID | \
    grep IPAddress | awk '{print $2}' | tr -d '":,')

check_hostname result $SHELL_HOSTNAME $SHELL_IP
until [ "$result" -eq 0 ]; do
    echo -n "."
    sleep 1
    check_hostname result $SHELL_HOSTNAME $SHELL_IP
done

echo ""
echo "***************************************************************"
echo "connect to shell via:"
echo "sudo docker attach $SHELL_ID"

