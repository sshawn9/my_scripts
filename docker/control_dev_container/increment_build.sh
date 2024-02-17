#!/bin/bash

set -e

current_date=$(date +%Y%m%d)

BASE_IMAGE=sshawn/control_dev:melodic_msgs_20240117
image_name=sshawn/control_dev:melodic_msgs_$current_date
docker build --build-arg BASE_IMAGE=$BASE_IMAGE --no-cache -f increment.Dockerfile -t $image_name .

BASE_IMAGE=sshawn/control_dev:noetic_msgs_20240117
image_name=sshawn/control_dev:noetic_msgs_$current_date
docker build --build-arg BASE_IMAGE=$BASE_IMAGE --no-cache -f increment.Dockerfile -t $image_name .

BASE_IMAGE=sshawn/control_dev:humble_msgs_20240117
image_name=sshawn/control_dev:humble_msgs_$current_date
docker build --build-arg BASE_IMAGE=$BASE_IMAGE --no-cache -f increment.Dockerfile -t $image_name .
