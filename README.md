# Dockerfiles for Spark and Shark

## Contents

Dockerfiles to build Spark 0.7.3 and Shark 0.7.0 images for testing and
development.

## Requirements

Tested on Ubuntu 12.04 Docker version 0.6.3 with the virtual
switch
	lxcbr0
enabled. For running Docker on Mac and Windows see [the docs](http://docs.docker.io).

## Building

The steps need to be followed in this order due to the
dependencies of the images

apache-hadoop-hdfs-precise -> spark-base -> spark-{master, worker, shell}

apache-hadoop-hdfs-precise -> spark-base -> shark-base -> shark-{master, worker, shell}

In order to build all images in the correct order initially do

	cd docker
	./build

You can (re-)build single images by cd-ing into the image directory and doing

	. build

## Testing

There are deploy scripts for both a standalone Spark cluster and
a standalone Spark/Shark cluster. In addition to Spark (and Shark)
the cluster also runs a Hadoop HDFS filesystem. When the deploy
script is run it generates one container for the master node,
one container for each worker node and one extra container running
a Dnsmasq DNS forwarder. The latter one can also be used to resolve
node names on the host, for example to access the worker logs via
the Spark web UI. Each node also runs a sshd which is pre-configured
with the given ssh RSA keys.

Both the Spark and Shark shells are started in a separate container.
This container can be directly started from the deploy scripts by
passing "-c" to the deploy script.


### Spark

1.	cd spark/deploy
2.	sudo ./deploy
3. wait for the "cluster" to come up
4. follow the command to start the spark-shell container
5. execute the steps inside test.spark

Note: after the cluster is up you should see something like this:

<pre>
started nameserver container:  c1f90063f51a
NAMESERVER_IP:                 10.0.3.129
started master container:      bbd5a7679463
MASTER_IP:                     10.0.3.130
started worker container:  9a1c8890ea92
started worker container:  ac1cc62f2980

***********************************************************************
connect to spark via:       sudo docker run -i -t -dns 10.0.3.129 spark-shell:0.7.3 10.0.3.130

visit Spark WebUI at:       http://10.0.3.130:8080/
visit Hadoop Namenode at:   http://10.0.3.130:50070
ssh into master via:        ssh -i ../../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@10.0.3.130

kill cluster via:           sudo docker kill bbd5a7679463
***********************************************************************

to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:
nameserver 10.0.3.129
</pre>

### Shark

1.	cd shark/deploy
2.	sudo ./deploy
3. wait for the "cluster" to come up
4. follow the command to start the shark-shell container
5. execute the steps inside test.shark

Note: after the cluster is up you should see something like this:

<pre>
started nameserver container:  654cdabbbe18
NAMESERVER_IP:                 10.0.3.133
started master container:      b0590e23e035
MASTER_IP:                     10.0.3.134
started worker container    42893bbd747a
started worker container    117665ebaf60

***********************************************************************
connect to shark via:       sudo docker run -i -t -dns 10.0.3.133 shark-shell:0.7.0 10.0.3.134

visit Spark WebUI at:       http://10.0.3.134:8080/
visit Hadoop Namenode at:   http://10.0.3.134:50070
ssh into master via:        ssh -i ../../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@10.0.3.134

kill cluster via:           sudo docker kill b0590e23e035
***********************************************************************

to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:
nameserver 10.0.3.133
</pre>

## Best practices for Dockerfiles and startup scripts

The following are just some comments that made the generation of the images easier. It
is not enforced in any way by Docker.

The images and startup scripts follow the following structure in order to reuse
as much as possible of the image they depend on. There are two types of images,
<em>base</em> images and <em>leaf</em> images. Leaf images, as the name suggests,
are images that are leafs in the dependency tree. For example, spark-base as a base
image depends on apache-hadoop-hdfs-precise. spark-master depends on spark-base as
its base image and is itself a leaf.

In addition to its Dockerfile, each image has a
	files/
subdirectory in its image directory that contains files (config files, data files) that will be copied
to the
	root/<em>image_name</em>_files
directory inside the image.

### Base images

Base images are images that are intended to be extended by other images and therefore do not
have a default command or entry point. They are good for testing though, e.g, by running
	/bin/bash
inside them. 


For base images such as spark-base, besides data files the
	files/
directory also contains
	files/configure_spark.sh
which is a script that contains four functions

*	create_spark_directories
  for creating required directories such as the working directory
*	deploy_spark_files
  that would copy files from
	/root/<em>image_name</em>_files
  to required system path locations
*	configure_spark
  that changes settings in config files and takes the IP of the master as argument
*	prepare_spark
  that calls the previous three in the given order and takes the IP of the master as argument


All of the functions of a __base-image__'s configure script, so also inside
	files/configure_spark.sh
except __prepare_spark__ first call their corresponding functions in the image the spark-base image depends on (apache-hadoop-hdfs-precise in this case). Therefore all the underlying services get initialized before the top level service. 

### Leaf images

For leaf images such as spark-master, besides data files the
	files/
directory also contains
	files/default_cmd
that is chosen in the image's Dockerfile to be the default command (or entry point) to the image. This means the command
inside is executed whenever the container is started.


The default command script executes the following steps in this order

1. The first thing the default command does is call the prepare
   function of the configure script inside its base image. In this case, the default command script calls function
	prepare_spark
   inside
	/root/spark-base/configure_spark.sh
which is the location the configure script of spark-base was copied to.
2. After that, now that the base images configuration (and the configuration of the images it inherits from) has completed, the
   default command may start services it relies on, such as the Hadoop namenode service in the case of spark-master.
3. Finally, the default command script of spark-master runs a second script under userid hdfs
   (the Hadoop HDFS super user), which is
	files/files/run_spark_master.sh
   that actually starts the master.
 

The spark-worker default command proceeds along the same lines but starts a Spark worker with a Hadoop datanode instead.

## Tips

### Name resolution on host

In order to resolve names (such as "master", "worker1", etc.) add the IP
of the nameserver container to the top of /etc/resolv.conf on the host.


### Killing all containers at once

This is a one-line script to kill all running containers at once:
	docker/kill_all

### Maintaining local Docker image repository

After a while building and debugging images the local image repository gets
full of intermediate images that serve no real purpose other than
debugging a broken build. To remove these do

	sudo docker images | grep "<none>" | awk '{print $3}' | xargs sudo docker rmi

Also data from stopped containers tend to accumulate. In order to remove all container data (__only do when no containers are running__) do

	sudo docker rm `sudo docker ps -a -q`
