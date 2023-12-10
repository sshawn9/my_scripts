#!/bin/bash

# install necessary packages for autonomous control development

# ---
# test information
# test passed on docker image ubuntu:18.04
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

$DO apt update
$DO apt-get install -y git \
                       git-lfs \
                       build-essential \
                       cmake \
                       make \
                       gcc \
                       g++ \
                       gdb \
                       libyaml-cpp-dev \
                       libeigen3-dev \
                       libgeographic-dev \
                       libtbb-dev \
                       libzmqpp-dev \
                       libfmt-dev \
                       libclass-loader-dev

git clone https://github.com/sshawn9/my_scripts.git
cd my_scripts
git lfs pull
cd installers
$DO bash install_osqp.sh
$DO bash install_protobuf.sh
cd ../..
rm -rf my_scripts
