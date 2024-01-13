#!/bin/bash

set -e

current_date=$(date +%Y%m%d)

BASE_IMAGE=ros:melodic-ros-core
image_name=sshawn/control_dev:melodic_msgs_$current_date
docker build --build-arg BASE_IMAGE=$BASE_IMAGE -t $image_name .

BASE_IMAGE=ros:noetic-ros-core
image_name=sshawn/control_dev:noetic_msgs_$current_date
docker build --build-arg BASE_IMAGE=$BASE_IMAGE -t $image_name .

BASE_IMAGE=ros:humble-ros-base
image_name=sshawn/control_dev:humble_msgs_$current_date
docker build --build-arg BASE_IMAGE=$BASE_IMAGE -t $image_name .
