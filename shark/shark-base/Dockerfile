# Spark 0.7.3, Shark 0.7.0
# Version 0.7.0
#
# Use spark-base as base
FROM spark-base:0.7.3
MAINTAINER AMPLab amplab@berkeley.edu

# note: SPARK_VERSION should be inherited from spark-base
# but for some reason isn't (?)
ENV SPARK_VERSION 0.7.3
ENV SHARK_VERSION 0.7.0
ENV HIVE_VERSION 0.9.0

# Install Shark
ADD http://spark-project.org/download/shark-${SHARK_VERSION}-hadoop1-bin.tgz /
RUN (cd / && gunzip < shark-${SHARK_VERSION}-hadoop1-bin.tgz)|(cd /opt && tar -xvf -)
RUN rm /shark-${SHARK_VERSION}-hadoop1-bin.tgz

# Add Shark config files and configure script
# NOTE: we rather do this as a single ADD statement
# since we are running into
# 	Error build: Unable to mount using aufs
# 	Unable to mount using aufs
# issue. For more information see
#	https://github.com/dotcloud/docker/issues/1171
ADD files /root/shark_files

