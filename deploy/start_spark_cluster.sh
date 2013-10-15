#!/bin/bash

MASTER=-1
MASTER_IP=

# starts the Spark master container
function start_spark_master() {
    echo "starting Spark master container"
    MASTER=$(sudo docker run -i -t -d -dns $NAMESERVER_IP -h master $VOLUME_MAP $1:$SPARK_VERSION)
    echo "started master container:      $MASTER"
    sleep 3
    MASTER_IP=$(sudo docker logs $MASTER 2>&1 | egrep '^MASTER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
    echo "MASTER_IP:                     $MASTER_IP"
    echo "address=\"/master/$MASTER_IP\"" >> $DNSFILE
}

# starts a number of Spark workers
function start_spark_workers() {
    for i in `seq 1 $NUM_WORKERS`; do
        echo "starting Spark worker container"
	hostname="worker${i}"
	WORKER=$(sudo docker run -d -dns $NAMESERVER_IP -h $hostname $VOLUME_MAP $1:${SPARK_VERSION} ${MASTER_IP} spark://${MASTER_IP}:7077)
	echo "started worker container:  $WORKER"
	sleep 3
	WORKER_IP=$(sudo docker logs $WORKER 2>&1 | egrep '^WORKER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
	echo "address=\"/$hostname/$WORKER_IP\"" >> $DNSFILE
    done
}

# prints out information on the cluster
function print_spark_cluster_info() {
    BASEDIR=$(cd $(dirname $0); pwd)"/.."
    echo ""
    echo "***********************************************************************"
    echo "connect to spark via:       sudo docker run -i -t -dns $NAMESERVER_IP -v $DNSDIR:/etc/dnsmasq.d amplab/spark-shell:$SPARK_VERSION $MASTER_IP"
    echo ""
    echo "visit Spark WebUI at:       http://$MASTER_IP:8080/"
    echo "visit Hadoop Namenode at:   http://$MASTER_IP:50070"
    echo "ssh into master via:        ssh -i $BASEDIR/apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${MASTER_IP}"
    echo ""
    echo "/data mapped:               $VOLUME_MAP"
    echo ""
    echo "kill cluster via:           sudo docker kill $MASTER"
    echo "***********************************************************************"
    echo ""
    echo "to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:"
    echo "nameserver $NAMESERVER_IP"
}
