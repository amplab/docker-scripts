# Base Ubuntu Precise 12.04 LTS image
#
FROM apache-hadoop-hdfs-precise:1.2.1
MAINTAINER AMPLab amplab@berkeley.edu

RUN apt-get install -y libcurl4-openssl-dev

# add Hadoop config file templates
# NOTE: we rather do this as a single ADD statement
# since we are running into
#       Error build: Unable to mount using aufs
#       Unable to mount using aufs
# issue. For more information see
#       https://github.com/dotcloud/docker/issues/1171
ADD files /root/mesos_files

RUN (mv /root/mesos_files/mesos.tgz / && cd / && gunzip < mesos.tgz)|(cd /opt && tar -xvf -)
RUN (rm /mesos.tgz && ln -s /opt/mesos /tmp/mesos)

ENV LD_LIBRARY_PATH /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server
