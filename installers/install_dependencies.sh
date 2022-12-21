#!/bin/bash

# install alomost all scripts under this folder

# ---
# test information
# test passed on docker image ubuntu:18.04
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

$DO apt install -y libgeographic-dev ros-melodic-plotjuggler-ros

scripts_dir=$(pwd)

$DO chmod +x $scripts_dir/*.sh

# $DO bash change_apt_source.sh
# $DO bash change_ros_source.sh
$DO bash install_ipopt.sh
$DO bash install_cppad.sh
$DO bash install_ceres.sh
$DO bash install_protobuf.sh
$DO bash install_gsl.sh
