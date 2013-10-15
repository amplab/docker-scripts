# Hadoop 1.2.1
# Version 1.2.1
#
FROM apache-hadoop-hdfs-precise:1.2.1

MAINTAINER amplab amp-docker@eecs.berkeley.edu

ENV SCALA_VERSION 2.9.3
ENV SPARK_VERSION 0.7.3
ENV SCALA_HOME /opt/scala-$SCALA_VERSION
ENV SPARK_HOME /opt/spark-$SPARK_VERSION
ENV PATH $SPARK_HOME:$SCALA_HOME/bin:$PATH

# Install Scala
ADD http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.tgz /
RUN (cd / && gunzip < scala-$SCALA_VERSION.tgz)|(cd /opt && tar -xvf -)
RUN rm /scala-$SCALA_VERSION.tgz

# Install Spark 
ADD http://spark-project.org/download/spark-$SPARK_VERSION-prebuilt-hadoop1.tgz /
RUN (cd / && gunzip < spark-$SPARK_VERSION-prebuilt-hadoop1.tgz)|(cd /opt && tar -xvf -)
RUN rm /spark-$SPARK_VERSION-prebuilt-hadoop1.tgz

# Add Spark config files and configure script
ADD files /root/spark_files
