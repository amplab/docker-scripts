#!/bin/bash
. /opt/shark-0.8.0/conf/shark-env.sh
export PATH=$PATH:$SCALA_HOME/bin
export CLASSPATH=$CLASSPATH:$SCALA_HOME/lib/scala-library.jar

/opt/spark-0.8.0/bin/start-master.sh

while [ 1 ];
do
    tail -f /opt/spark-${SPARK_VERSION}/logs/*.out
    sleep 1
done
