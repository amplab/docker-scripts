#!/bin/bash

source /root/shark_files/configure_shark.sh

function create_mesos_directories() {
    create_shark_directories
    mkdir /tmp/mesos
    chown hdfs.hdfs /tmp/mesos
}

function deploy_mesos_files() {
    deploy_shark_files
}		

function configure_mesos() {
    configure_shark $1
    sed -i s/"^export MASTER="/"#export MASTER="/ /opt/spark-$SPARK_VERSION/conf/spark-env.sh
    echo "export MASTER=mesos://$1:5050" >> /opt/spark-$SPARK_VERSION/conf/spark-env.sh
    echo "export MESOS_NATIVE_LIBRARY=/opt/mesos/lib/libmesos-0.13.0.so" >> /opt/spark-$SPARK_VERSION/conf/spark-env.sh
    echo "export JAVA_LIBRARY_PATH=/opt/mesos/lib/libmesos-0.13.0.so" >> /opt/spark-$SPARK_VERSION/conf/spark-env.sh
}

function prepare_mesos() {
    create_mesos_directories
    deploy_mesos_files
    configure_mesos $1
}
