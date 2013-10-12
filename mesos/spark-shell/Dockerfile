# Spark
FROM amplab/mesos-base:0.13.0
MAINTAINER amplab amp-docker@eecs.berkeley.edu

ADD files /root/spark_shell_files

# Add the entrypoint script for the master
ENTRYPOINT ["/root/spark_shell_files/default_cmd"]
