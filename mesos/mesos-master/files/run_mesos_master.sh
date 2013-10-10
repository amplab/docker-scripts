#!/bin/bash
export LD_LIBRARY_PATH=/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server
cd /opt/mesos/sbin && ./mesos-master --ip=$1
