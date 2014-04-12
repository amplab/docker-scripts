# Dockerfiles for Spark and Shark

## Contents

Dockerfiles to build Spark and Shark images for testing and
development.

## Requirements

Tested on Ubuntu 12.04 (Docker version 0.6.4), Ubuntu 13.10 (Docker 0.7.0 and 0.9.0) with the virtual
switch
	lxcbr0
enabled. For running Docker on Mac and Windows see [the docs](http://docs.docker.io).
Also tested inside the VirtualBox Tiny Core Linux VirtualBox VM for Docker on
Mac.

Note: the earlier version of the scripts had problems with newer
versions of Docker (0.7). If you encounter issues please pull the
latest changes from https://github.com/amplab/docker-scripts.git
master branch.

__Important!__ If you are running on Mac OS, installed as described
[in the Docker installation docs](http://docs.docker.io/en/latest/installation/mac/)
you need to run all commands inside the Docker virtual machine by first ssh-ing into it:

<pre>
$ ./boot2docker ssh
# User: docker
# Pwd:  tcuser
</pre>

Then make sure that `python` is installed. Otherwise install it via
`tce-ab` (search for python and install `python.tcz`).

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
                 amplab/spark:0.7.3  amplab/spark:0.8.0  amplab/spark:0.9.0
                 amplab/shark:0.7.3  amplab/shark:0.8.0
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

	$ sudo ./deploy/deploy.sh -i amplab/spark:0.9.0 -w 3 

#### Wait a few seconds

Wait for the "cluster" to come up. Note that it can take longer to download
the container images the first time but after that the process is fairly quick.
When the cluster comes up you should see something like this:

<pre>
> sudo ./deploy.sh -i amplab/spark:0.9.0 -w 3 
*** Starting Spark 0.9.0 ***
starting nameserver container
started nameserver container:  069557913d98a37caf43f8238dfdf181aea5ab30eb42e382db83307e277cfa9e
DNS host->IP file mapped:      /tmp/dnsdir_12015/0hosts
NAMESERVER_IP:                 172.17.0.8
waiting for nameserver to come up 
starting master container
started master container:      f50a65d2ef7b17bffed7075ac2de4a7b52c26adff15bdbe14d3280ef4991c9d6
MASTER_IP:                     172.17.0.9
waiting for master ........
waiting for nameserver to find master 
starting worker container
started worker container:  576d7d223f59a6da7a0e73311d1e082fad27895aef53edf3635264fb00b70258
starting worker container
started worker container:  5672ea896e179b51fe2f1ae5d542c35706528cd3a768ba523324f434bb2b2413
starting worker container
started worker container:  3cdf681f7c99c1e19f7b580ac911e139923e9caca943fd006fb633aac5b20001
waiting for workers to register .....

***********************************************************************
start shell via:            sudo /home/andre/docker-scripts/deploy/start_shell.sh -i amplab/spark-shell:0.9.0 -n 069557913d98a37caf43f8238dfdf181aea5ab30eb42e382db83307e277cfa9e 

visit Spark WebUI at:       http://172.17.0.9:8080/
visit Hadoop Namenode at:   http://172.17.0.9:50070
ssh into master via:        ssh -i /home/andre/docker-scripts/deploy/../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.17.0.9

/data mapped:               

kill master via:           sudo docker kill f50a65d2ef7b17bffed7075ac2de4a7b52c26adff15bdbe14d3280ef4991c9d6
***********************************************************************

to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:
nameserver 172.17.0.8
</pre>

#### Start the Spark shell container as shown above, for example:

	$ sudo /home/andre/docker-scripts/deploy/start_shell.sh -i amplab/spark-shell:0.9.0 -n 069557913d98a37caf43f8

The parameter passed with -n is the ID of the nameserver container.
Then attach to the running shell via the given command, for example:

    $ sudo docker attach 9ac49b09bf18a13c7

If the screen appears to stay blank just hit return to get to the prompt.

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

Wait for the "cluster" to come up. Note that it can take longer to download
the container images the first time but after that the process is fairly quick.
When the cluster comes up you should see something like this:

<pre>
*** Starting Shark 0.8.0 + Spark ***
starting nameserver container
started nameserver container:  952d22e085c3b74e829e006ab536d45d31800c463832e43d8679bbf3d703940e
DNS host->IP file mapped:      /tmp/dnsdir_30578/0hosts
NAMESERVER_IP:                 172.17.0.13
waiting for nameserver to come up 
starting master container
started master container:      169f253eaddadb19b6eb28e79f148eef892f20d34602ffb42d3e57625dc61652
MASTER_IP:                     172.17.0.14
waiting for master ........
waiting for nameserver to find master 
starting worker container
started worker container:  1c6920c96d5ad684a2f591bfb334323c5854cdd7a0da49982baaf77dc4d62ac7
starting worker container
started worker container:  7250dcfb882e2d17441c8c59361d10d8c59afb2b295719ba35f59bc72c6f17a5
starting worker container
started worker container:  26823e188a2a5a5897ed4b9bf0fca711dc7f98674fe62eb78fb49cf031bec79c
waiting for workers to register .......

***********************************************************************
start shell via:            sudo /home/andre/docker-scripts/deploy/start_shell.sh -i amplab/shark-shell:0.8.0 -n 952d22e085c3b74e829e006ab536d45d31800c463832e43d8679bbf3d703940e 

visit Spark WebUI at:       http://172.17.0.14:8080/
visit Hadoop Namenode at:   http://172.17.0.14:50070
ssh into master via:        ssh -i /home/andre/docker-scripts/deploy/../apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.17.0.14

/data mapped:               

kill master via:           sudo docker kill 169f253eaddadb19b6eb28e79f148eef892f20d34602ffb42d3e57625dc61652
***********************************************************************

to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:
nameserver 172.17.0.13
</pre>

#### Start the Shark shell container as shown above, for example:

	$ sudo /home/andre/docker-scripts/deploy/start_shell.sh -i amplab/shark-shell:0.8.0 -n 952d22e085c3b74e829e00

The parameter passed with -n is the ID of the nameserver container.
Then attach to the running shell via the given command, for example:

    $ sudo docker attach 9ac49b09bf18a13c7

If the screen appears to stay blank just hit return to get to the prompt.

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
