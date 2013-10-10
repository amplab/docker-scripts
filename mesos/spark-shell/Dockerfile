# Spark
FROM mesos-base:0.13.0
MAINTAINER AMPLab amplab@berkeley.edu

ADD files /root/spark_shell_files

# Add the entrypoint script for the master
ENTRYPOINT ["/root/spark_shell_files/default_cmd"]
