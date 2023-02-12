#!/bin/bash

# install osqp on ubuntu

# ---
# test information
# test passed on docker image ubuntu:18.04
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO


function apt_install {
    $DO apt update
    $DO apt install -y cmake gcc g++
}

function work_dir {
    $DO rm -rf tmp_osqp
    mkdir tmp_osqp
    cd tmp_osqp
}

function install_osqp {
    cp ../packages/osqp*.tar.gz .
    tar -xf osqp*.tar.gz
    rm -rf osqp*.tar.gz
    cd osqp*
    mkdir build
    cd build
    cmake -G "Unix Makefiles" ..
    cmake --build . --target install
}

function del_dir {
    cd ../../..
    rm -rf tmp_osqp
}

apt_install
work_dir
install_osqp
del_dir

