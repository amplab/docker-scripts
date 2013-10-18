#!/bin/bash

source /root/spark_files/configure_spark.sh

shark_files=( "/root/shark_files/shark-env.sh" )
hive_files=( "/root/shark_files/hive-site.xml" "/etc/hadoop/core-site.xml" )

function create_shark_directories() {
    create_spark_directories
    rm -rf /opt/metastore
    mkdir /opt/metastore
    chown hdfs.hdfs /opt/metastore
}

function deploy_shark_files() {
    deploy_spark_files
    for i in "${hive_files[@]}";
    do
        filename=$(basename $i);
        cp $i /opt/hive-${HIVE_VERSION}-bin/conf/$filename;
    done
    for i in "${shark_files[@]}";
    do
	filename=$(basename $i);
	cp $i /opt/shark-${SHARK_VERSION}/conf/$filename;
    done	
}		

function configure_shark() {
    configure_spark $1
    # Shark
    sed -i s/__SPARK_HOME__/"\/opt\/spark-${SPARK_VERSION}"/ /opt/shark-$SHARK_VERSION/conf/shark-env.sh
    sed -i s/__HIVE_HOME__/"\/opt\/hive-${HIVE_VERSION}-bin"/ /opt/shark-$SHARK_VERSION/conf/shark-env.sh
    # Hive
    sed -i s/__MASTER__/$1/ /opt/hive-0.9.0-bin/conf/hive-site.xml
    #sed -i s/__MASTER__/master/ /opt/hive-0.9.0-bin/conf/hive-site.xml
}

function prepare_shark() {
    create_shark_directories
    deploy_shark_files
    configure_shark $1
}
