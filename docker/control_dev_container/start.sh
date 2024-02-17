#!/bin/bash

set -e

tag="humble_msgs_20240217"
tag="melodic_msgs_20240217"
tag="noetic_msgs_20240217"
image="sshawn/control_dev:$tag"

docker run -itd \
           -v ~:/star \
           -v ~/Documents/GitHub:/GitHub \
           -v ~/Documents/Github/autonomous:/root/autonomous \
           -v ~/Documents/Github/autonomous/workspace/src:/src \
           -v /etc/localtime:/etc/localtime:ro \
           --privileged \
           --name $tag \
           --hostname $tag \
           $image \
           bash
