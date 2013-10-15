#!/bin/bash
. /opt/spark-0.7.3/conf/spark-env.sh
#/opt/spark-0.7.3/run spark.deploy.worker.Worker -i $(hostname) $1
/opt/spark-0.7.3/run spark.deploy.worker.Worker -i $(hostname) spark://master:7077
