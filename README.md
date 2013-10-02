# Dockerfiles for Spark and Shark

## Contents

Dockerfiles to build Spark 0.7.3 and Shark 0.7.0 images for testing and
development.

## Building

The steps need to be followed in this order due to the
dependencies of the images

apache-hadoop-hdfs-precise -> spark-base -> spark-{master, worker, shell}

apache-hadoop-hdfs-precise -> spark-base -> shark-base -> shark-{master, worker, shell}

You can (re-)build single images by cd-ing into the image directory and doing

	. build

In order to build all images in the correct order initially follow the steps
below.

1. Hadoop base image:

	cd apache-hadoop-hdfs-precise

	. build

2. Spark:

	cd spark/build

	./build

3. Shark:

	cd shark/build

	./build

## Testing

### Spark

1.	cd spark/deploy
2.	sudo ./deploy
3. wait for the "cluster" to come up
4. follow the command to start the spark-shell container
5. execute the steps inside test.spark

### Shark

1.	cd shark/deploy
2.	sudo ./deploy
3. wait for the "cluster" to come up
4. follow the command to start the shark-shell container
5. execute the steps inside test.shark

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
