#!/bin/bash
. /opt/spark-0.7.3/conf/spark-env.sh
/opt/spark-0.7.3/run spark.deploy.worker.Worker spark://master:7077
