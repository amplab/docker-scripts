#!/bin/bash

hadoop_files=( "/root/hadoop_files/core-site.xml"  "/root/hadoop_files/hdfs-site.xml" )

function create_hadoop_directories() {
    :
}

function deploy_hadoop_files() {
    for i in "${hadoop_files[@]}";
    do
        filename=$(basename $i);
        cp $i /etc/hadoop/$filename;
    done
}		

function configure_hadoop() {
    sed -i s/__MASTER__/$1/ /etc/hadoop/core-site.xml
    sed -i s/"JAVA_HOME=\/usr\/lib\/jvm\/java-6-sun"/"JAVA_HOME=\/usr\/lib\/jvm\/java-6-openjdk-amd64"/ /etc/hadoop/hadoop-env.sh
}

function prepare_hadoop() {
    create_hadoop_directories
    deploy_hadoop_files
    configure_hadoop $1
}
