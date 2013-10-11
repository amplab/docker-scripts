# Mesos
FROM amplab/mesos-base:0.13.0
MAINTAINER amplab amp-docker@eecs.berkeley.edu

# Setup a volume for data
#VOLUME ["/data"]

ADD files /root/mesos_master_files

CMD ["/root/mesos_master_files/default_cmd"]
