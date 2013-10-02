#!/bin/bash

source /root/hadoop_files/configure_hadoop.sh

function create_spark_directories() {
    create_hadoop_directories
    rm -rf /opt/spark-$SPARK_VERSION/work
    mkdir -p /opt/spark-$SPARK_VERSION/work
    chown hdfs.hdfs /opt/spark-$SPARK_VERSION/work
    # this one is for Spark shell logging
    rm -rf /var/lib/hadoop/hdfs
    mkdir -p /var/lib/hadoop/hdfs
    chown hdfs.hdfs /var/lib/hadoop/hdfs
}

function deploy_spark_files() {
    deploy_hadoop_files
}		

function configure_spark() {
    configure_hadoop $1
}

function prepare_spark() {
    create_spark_directories
    deploy_spark_files
    configure_spark $1
}
