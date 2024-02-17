#!/bin/bash

set -e

tag="humble_msgs_20240117"
tag="melodic_msgs_20240117"
tag="noetic_msgs_20240117"
image="sshawn/control_dev:$tag"

docker run -itd \
           -v ~:/star \
           -v ~/Documents/GitHub:/GitHub \
           -v ~/Documents/Github/autonomous:/root/autonomous \
           -v ~/Documents/Github/autonomous/workspace/src:/src \
           --name $tag \
           --hostname $tag \
           $image \
           bash
