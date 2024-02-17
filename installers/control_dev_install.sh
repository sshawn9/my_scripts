#!/bin/bash

# install necessary packages for autonomous control development

# ---
# test information
# test passed on following docker image:
# - ros:melodic-ros-core
# - ros:noetic-ros-core
# - ros:humble-ros-base
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

$DO apt update
$DO apt-get install -y wget \
                       build-essential \
                       cmake \
                       make \
                       gcc \
                       g++ \
                       gdb \
                       htop \
                       libyaml-cpp-dev \
                       libeigen3-dev \
                       libgeographic-dev \
                       libboost-all-dev \
                       libzmq3-dev \
                       libtbb-dev \
                       liblmdb++-dev

install_protobuf_url=https://raw.githubusercontent.com/sshawn9/my_scripts/master/installers/install_protobuf.sh
install_protobuf_url=https://raw.kkgithub.com/sshawn9/my_scripts/master/installers/install_protobuf.sh

wget -t 10 $install_protobuf_url
$DO bash install_protobuf.sh
rm -rf install_protobuf.sh

$DO apt-get install -y ros-$ROS_DISTRO-ackermann-msgs
