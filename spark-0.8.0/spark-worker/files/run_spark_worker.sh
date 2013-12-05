#!/bin/bash
. /opt/spark-0.8.0/conf/spark-env.sh
${SPARK_HOME}/spark-class org.apache.spark.deploy.worker.Worker $MASTER
