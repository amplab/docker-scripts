#!/bin/bash

source /root/hadoop_files/configure_hadoop.sh

function create_mesos_directories() {
    create_hadoop_directories
}

function deploy_mesos_files() {
    deploy_hadoop_files
}		

function configure_mesos() {
    configure_hadoop $1
}

function prepare_mesos() {
    create_mesos_directories
    deploy_mesos_files
    configure_mesos $1
}
