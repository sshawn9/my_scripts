#!/bin/bash

# change ros source to tsinghua

# ---
# test information
# test passed on docker image ubuntu:18.04
# test passed on docker image ros:melodic-ros-core-bionic
# ---


# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

dir="/etc/apt/sources.list.d/"

files=`ls ${dir} | grep -E "ros.*list$"`

if [ -z "$files" ]; then exit 0; fi

for f in $files
do
    $DO cp $dir$f $dir$f.back
    $DO sed -i 's/packages.ros.org/mirrors.tuna.tsinghua.edu.cn/g' $dir$f
done
