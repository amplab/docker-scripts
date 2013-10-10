#!/bin/bash

MASTER=-1
MASTER_IP=

# starts the Mesos master container
function start_mesos_master() {
    echo "starting Mesos master container"
    MASTER=$(sudo docker run -i -t -d -dns $NAMESERVER_IP -h master mesos-master:$MESOS_VERSION)
    echo "started master container:      $MASTER"
    sleep 3
    MASTER_IP=$(sudo docker logs $MASTER 2>&1 | egrep '^MASTER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
    echo "MASTER_IP:                     $MASTER_IP"
    echo "address=\"/master/$MASTER_IP\"" >> $DNSFILE
}

# starts a number of Mesos workers
function start_mesos_workers() {
    for i in `seq 1 $NUM_WORKERS`; do
        echo "starting Mesos worker container"
        hostname="worker${i}"
        WORKER=$(sudo docker run -d -dns $NAMESERVER_IP -h $hostname mesos-worker:${MESOS_VERSION} ${MASTER_IP} ${MASTER_IP}:5050)
        echo "started worker container:  $WORKER"
        sleep 3
        WORKER_IP=$(sudo docker logs $WORKER 2>&1 | egrep '^WORKER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
        echo "address=\"/$hostname/$WORKER_IP\"" >> $DNSFILE
    done
}

# prints out information on the cluster
function print_cluster_info() {
    echo ""
    echo "***********************************************************************"
    echo "visit Mesos WebUI at:       http://$MASTER_IP:5050/"
    echo "visit Hadoop Namenode at:   http://$MASTER_IP:50070"
    echo ""
    echo "start Spark Shell:          sudo docker run -i -t -dns $NAMESERVER_IP -h spark-client spark-shell-mesos:0.7.3 $MASTER_IP"
    echo "start Shark Shell:          sudo docker run -i -t -dns $NAMESERVER_IP -h shark-client shark-shell-mesos:0.7.0 $MASTER_IP"
    echo ""
    echo "ssh into master via:        ssh -i ../../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${MASTER_IP}"
    echo ""
    echo "kill cluster via:           docker/kill_all"
    echo "***********************************************************************"
    echo ""
    echo "to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:"
    echo "nameserver $NAMESERVER_IP"
}

