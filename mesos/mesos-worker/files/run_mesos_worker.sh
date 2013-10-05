#!/bin/bash
cd /opt/mesos/sbin && ./mesos-slave --master=$1 --ip=$2 --hadoop_home=$HADOOP_HOME
