#!/bin/bash

# change apt source to tsinghua on ubuntu

# ---
# test information
# passed on docker image ubuntu:18.04
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

cd /etc/apt
$DO cp sources.list sources.list.back
$DO sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g'  /etc/apt/sources.list
$DO sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g'  /etc/apt/sources.list