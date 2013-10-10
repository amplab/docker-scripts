# Shark worker
FROM shark-base:0.7.0
MAINTAINER AMPLab amplab@berkeley.edu

# Instead of using a random port, bind the worker to a specific port
# Note: Here we assume the virtual bridge is used!
ENV SPARK_WORKER_PORT 8888

# Add run script
ADD files /root/shark_worker_files

# Add the entrypoint script for the worker
ENTRYPOINT ["/root/shark_worker_files/default_cmd"]
