#!/bin/bash
. /opt/shark-0.7.0/conf/shark-env.sh
export PATH=$PATH:$SCALA_HOME/bin
export CLASSPATH=$CLASSPATH:$SCALA_HOME/lib/scala-library.jar
#/opt/spark-0.7.3/run spark.deploy.worker.Worker $1
#/opt/spark-0.7.3/run spark.deploy.worker.Worker -i $(hostname) spark://master:7077
${SPARK_HOME}/run spark.deploy.worker.Worker spark://master:7077
