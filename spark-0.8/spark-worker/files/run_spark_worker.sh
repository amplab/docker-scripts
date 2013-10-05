#!/bin/bash
. /opt/spark-0.8.0/conf/spark-env.sh
/opt/spark-0.8.0/spark-class org.apache.spark.deploy.worker.Worker $1
