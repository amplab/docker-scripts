#!/bin/bash
. /opt/spark-1.0.0/conf/spark-env.sh
${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.worker.Worker $MASTER
