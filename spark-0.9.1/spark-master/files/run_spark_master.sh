#!/bin/bash
/opt/spark-0.9.1/sbin/start-master.sh

while [ 1 ];
do
	tail -f /opt/spark-${SPARK_VERSION}/logs/*.out
        sleep 1
done
