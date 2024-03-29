#!/bin/bash

# install ceres on ubuntu

# ---
# test information
# test passed on docker image ubuntu:18.04
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

function install_dependency {
    $DO apt update
    $DO apt install -y cmake libgoogle-glog-dev libgflags-dev libatlas-base-dev libeigen3-dev wget curl gcc g++
}

function work_dir {
    $DO rm -rf tmp_ceres
    mkdir tmp_ceres
    cd tmp_ceres
}

function install_ceres {
    # wget ceres_url -O ceres.tar.gz
    cp ../packages/ceres-solver*.tar.gz .
    tar -zxf ceres-solver*.tar.gz
    rm -rf ceres-solver*.tar.gz
    mkdir ceres-bin
    cd ceres-bin
    cmake ../ceres-solver*
    make -j$(nproc)
    # make test
    $DO make install
}

function del_dir {
    cd ../..
    rm -rf tmp_ceres
}

install_dependency
work_dir
install_ceres
del_dir
