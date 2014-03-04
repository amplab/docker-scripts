#!/bin/bash

if [[ "$USER" != "root" ]]; then
    echo "please run as: sudo $0"
    exit 1
fi

image_list=("spark-master:0.9.0" "spark-worker:0.9.0" "spark-shell:0.9.0" "shark-master:0.8.0" "shark-worker:0.8.0" "shark-shell:0.8.0" )

IMAGE_PREFIX="amplab/"

# NOTE: the order matters but this is the right one
for i in ${image_list[@]}; do
	image=$(echo $i | awk -F ":" '{print $1}')
        echo docker tag ${IMAGE_PREFIX}${i} ${IMAGE_PREFIX}${image}:latest
	docker tag ${IMAGE_PREFIX}${i} ${IMAGE_PREFIX}${image}:latest
done
