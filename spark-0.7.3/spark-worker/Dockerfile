# Spark 0.7.3
# Version 0.7.3
FROM spark-base:0.7.3
MAINTAINER amplab amp-docker@eecs.berkeley.edu

ADD files /root/spark_worker_files

# Add the entrypoint script for the master
CMD ["-h"]
ENTRYPOINT ["/root/spark_worker_files/default_cmd"]
