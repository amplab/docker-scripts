# Mesos
FROM amplab/mesos-base:0.13.0
MAINTAINER amplab amp-docker@eecs.berkeley.edu

# Setup a volume for data
#VOLUME ["/data"]

ADD files /root/mesos_worker_files

# Add the entrypoint script for the master
CMD ["-h"]
ENTRYPOINT ["/root/mesos_worker_files/default_cmd"]
