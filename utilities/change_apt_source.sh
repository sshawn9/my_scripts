#!/bin/bash

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

cd /etc/apt
$DO cp sources.list sources.list.back
$DO sed -i 's|http://.*.ubuntu.com|http://mirrors.tuna.tsinghua.edu.cn|g'  /etc/apt/sources.list
$DO sed -i 's|security.ubuntu.com|mirrors.tuna.tsinghua.edu.cn|g'  /etc/apt/sources.list
