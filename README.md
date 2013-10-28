# Dockerfiles for Spark and Shark

## Contents

Dockerfiles to build Spark and Shark images for testing and
development.

## Requirements

Tested on Ubuntu 12.04 Docker version 0.6.4 with the virtual
switch
	lxcbr0
enabled. For running Docker on Mac and Windows see [the docs](http://docs.docker.io).

## Testing

First clone the repository:

	$ git clone https://github.com/amplab/docker-scripts.git

This repository contains deploy scripts and the sources for the Docker
image files, which can be easily modified. The main deploy script
takes the following options.

<pre>
$ sudo ./deploy/deploy.sh
usage: ./deploy.sh -i &lt;image&gt; [-w &lt;&#35;workers&gt;] [-v &lt;data_directory&gt;] [-c]

  image:    spark or shark image from:
                 amplab/spark:0.7.3  amplab/spark:0.8.0
                 amplab/shark:0.7.0  amplab/shark:0.8.0
</pre>

The script either starts a standalone Spark cluster or a standalone
Spark/Shark cluster for a given number of worker nodes. Note that
on the first call it may take a while for Docker to download the
various images from the repository,

In addition to Spark (and Shark) the cluster also runs a Hadoop HDFS
filesystem. When the deploy script is run it generates one container
for the master node, one container for each worker node and one extra
container running a Dnsmasq DNS forwarder. The latter one can also be
used to resolve node names on the host, for example to access the
worker logs via the Spark web UI. Each node also runs a sshd which is
_pre-configured with the given RSA key_. Note that you should change
this key if you plan to expose services running inside the containers.

Optionally one can set the number of workers (default: 2) and a data directory
which is a local path on the host that can be mounted on the master and
worker containers and will appear under /data.

Both the Spark and Shark shells are started in a separate container.
This container can be directly started from the deploy script by
passing "-c" to the deploy script.

### Example: Running a Spark cluster

Starting from the directory in which the repository was cloned do

#### Deploy the cluster

	$ sudo ./deploy/deploy.sh -i amplab/spark:0.8.0 -w 3 

#### Wait a few seconds

Wait for the "cluster" to come up. Note: after the cluster is up you should see something like this:

<pre>
*** Starting Spark 0.8.0 ***
starting nameserver container
started nameserver container:  72633d3612ea
DNS host->IP file mapped:      /tmp/dnsdir_10440/0hosts
NAMESERVER_IP:                 172.17.0.90
waiting for nameserver to come up 
starting master container
started master container:      7498d87db939
MASTER_IP:                     172.17.0.91
waiting for master ..................
waiting for nameserver to find master 
starting worker container
started worker container:  db977053c6b2
starting worker container
started worker container:  66a75c55752a
starting worker container
started worker container:  053988c65196
waiting for workers to register .....

***********************************************************************
connect to via:             sudo docker run -i -t -dns 172.17.0.90 amplab/spark-shell:0.8.0

visit Spark WebUI at:       http://172.17.0.91:8080/
visit Hadoop Namenode at:   http://172.17.0.91:50070
ssh into master via:        ssh -i /home/andre/docker/deploy/../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.17.0.91

/data mapped:               

kill cluster via:           sudo docker kill 7498d87db939
***********************************************************************

to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:
nameserver 172.17.0.90
</pre>

#### Start the Spark shell container as shown above, for example:

	$ sudo docker run -i -t -dns 172.17.0.90 amplab/spark-shell:0.8.0

#### Execute an example:

<pre>
scala&gt; val textFile = sc.textFile("hdfs://master:9000/user/hdfs/test.txt")
scala&gt; textFile.count()
scala&gt; textFile.map({line => line}).collect()
</pre>


#### Terminate the cluster:

	$ sudo ./deploy/kill_all.sh spark
	$ sudo ./deploy/kill_all.sh nameserver

### Shark

Basically the same steps apply only that the Shark images are chosen instead of the Spark ones
(the former contain in addition to Spark the Shark binaries).

#### Deploy the cluster

	$ sudo ./deploy/deploy.sh -i amplab/shark:0.8.0 -w 3

#### Wait a few seconds

Wait for the "cluster" to come up. Note: after the cluster is up you should see something like this:

<pre>
*** Starting Shark 0.8.0 + Spark ***
starting nameserver container
started nameserver container:  3afa9bb9f2cb
DNS host->IP file mapped:      /tmp/dnsdir_3620/0hosts
NAMESERVER_IP:                 172.17.0.84
waiting for nameserver to come up 
starting master container
started master container:      5e91d29ae61c
MASTER_IP:                     172.17.0.85
waiting for master .............
waiting for nameserver to find master 
starting worker container
started worker container:  b958be515616
starting worker container
started worker container:  df34ae552bca
starting worker container
started worker container:  33446470b323
waiting for workers to register ........

***********************************************************************
connect to via:             sudo docker run -i -t -dns 172.17.0.84 amplab/shark-shell:0.8.0 172.17.0.85

visit Spark WebUI at:       http://172.17.0.85:8080/
visit Hadoop Namenode at:   http://172.17.0.85:50070
ssh into master via:        ssh -i /home/andre/docker/deploy/../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.17.0.85

/data mapped:               

kill cluster via:           sudo docker kill 5e91d29ae61c
***********************************************************************

to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:
nameserver 172.17.0.84  
</pre>

#### Start the Shark shell container as shown above, for example:

	$ sudo docker run -i -t -dns 172.17.0.84 amplab/shark-shell:0.8.0 172.17.0.85

#### Execute an example:

<pre>
shark> CREATE TABLE src(key INT, value STRING);
shark> LOAD DATA LOCAL INPATH '${env:HIVE_HOME}/examples/files/kv1.txt' INTO TABLE src;
shark> SELECT COUNT(1) FROM src;
</pre>

#### Terminate the cluster:

	$ sudo ./deploy/kill_all.sh shark
	$ sudo ./deploy/kill_all.sh nameserver


## Building

If you prefer to build the images yourself (or intend to modify them) rather
than downloading them from the Docker repository, you can build
all Spark and Shark images in the correct order via the build script:

	$ ./build/build_all.sh

The script builds the images in an order that satisfies the chain of
dependencies:

apache-hadoop-hdfs-precise -> spark-base -> spark-{master, worker, shell}

apache-hadoop-hdfs-precise -> spark-base -> shark-base -> shark-{master, worker, shell}

You can always (re-)build single images by cd-ing into the image directory and doing

	$ . build

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

### Maintaining local Docker image repository

After a while building and debugging images the local image repository gets
full of intermediate images that serve no real purpose other than
debugging a broken build. To remove these do

	$ sudo docker images | grep "<none>" | awk '{print $3}' | xargs sudo docker rmi

Also data from stopped containers tend to accumulate. In order to remove all container data (__only do when no containers are running__) do

	$ sudo docker rm `sudo docker ps -a -q`
