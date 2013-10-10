#!/usr/bin/env bash
export SCALA_HOME=/opt/scala-2.9.3
export SPARK_HOME=__SPARK_HOME__
export SPARK_WORKER_CORES=1
export SPARK_MEM=700m
export SPARK_WORKER_MEMORY=700m
export SPARK_WORKER_CORES=1
export HADOOP_HOME="/etc/hadoop"
export MASTER="spark://__MASTER__:7077"
SPARK_JAVA_OPTS="-Dspark.local.dir=/tmp/spark "
SPARK_JAVA_OPTS+="-Dspark.kryoserializer.buffer.mb=10 "
SPARK_JAVA_OPTS+="-verbose:gc -XX:-PrintGCDetails -XX:+PrintGCTimeStamps "
export SPARK_JAVA_OPTS
export JAVA_HOME=__JAVA_HOME__
