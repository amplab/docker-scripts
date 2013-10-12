# Spark 0.7.3
# Version 0.7.3
FROM amplab/spark-base:0.7.3
MAINTAINER amplab amp-docker@eecs.berkeley.edu

# Expose TCP ports 7077 8080
EXPOSE 7077 8080

ADD files /root/spark_master_files

CMD ["/root/spark_master_files/default_cmd"]
