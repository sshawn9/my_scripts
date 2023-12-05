#!/bin/bash

set -e
ROS_DISTRO=noetic

docker build --build-arg ROS_DISTRO=${ROS_DISTRO} -t sshawn/plotjuggler:${ROS_DISTRO} .
