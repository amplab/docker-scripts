# Shark master
FROM shark-base:0.7.0
MAINTAINER AMPLab amplab@berkeley.edu

# Setup a volume for data
VOLUME ["/data"]

# Note: we assume the virtual bridge is used!

# Add run script
ADD files /root/shark_master_files

# Add default command for master
CMD ["/root/shark_master_files/default_cmd"]

