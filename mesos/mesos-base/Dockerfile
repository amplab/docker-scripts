# Base Ubuntu Precise 12.04 LTS image
#
FROM amplab/shark-base:0.7.0
MAINTAINER amplab amp-docker@eecs.berkeley.edu

#RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libcurl3

# add Hadoop config file templates
# NOTE: we rather do this as a single ADD statement
# since we are running into
#       Error build: Unable to mount using aufs
#       Unable to mount using aufs
# issue. For more information see
#       https://github.com/dotcloud/docker/issues/1171
ADD files /root/mesos_files

RUN (mv /root/mesos_files/mesos.tgz / && cd / && gunzip < mesos.tgz)|(cd /opt && tar -xvf -) && (rm /mesos.tgz && ln -s /opt/mesos /tmp/mesos)

