# Spark 0.8.0, Shark 0.8.0
#
# Use spark-base as base
FROM spark-base:0.8.0
MAINTAINER amplab amp-docker@eecs.berkeley.edu

# note: SPARK_VERSION should be inherited from spark-base
# but for some reason isn't (?)
ENV SPARK_VERSION 0.8.0
ENV SHARK_VERSION 0.8.0
ENV HIVE_VERSION 0.9.0

# Install Shark
ADD https://github.com/amplab/shark/releases/download/v${SHARK_VERSION}/shark-${SHARK_VERSION}-bin-hadoop1.tgz /
RUN (cd / && gunzip < shark-${SHARK_VERSION}-bin-hadoop1.tgz)|(cd /opt && tar -xvf -)
RUN (ln -s /opt/shark-${SHARK_VERSION}-bin-hadoop1/shark-${SHARK_VERSION} /opt/shark-${SHARK_VERSION} && ln -s /opt/shark-${SHARK_VERSION}-bin-hadoop1/hive-${HIVE_VERSION}-shark-${SHARK_VERSION}-bin /opt/hive-${HIVE_VERSION}-bin && rm /shark-${SHARK_VERSION}-bin-hadoop1.tgz)

# Add Shark config files and configure script
ADD files /root/shark_files

