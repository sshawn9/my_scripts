#!/bin/bash

# install gsl on ubuntu

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
    $DO apt install -y cmake gcc g++
}

function work_dir {
    $DO rm -rf tmp_gsl
    mkdir tmp_gsl
    cd tmp_gsl
}

function install_gsl {
    # wget ceres_url -O ceres.tar.gz
    cp ../packages/gsl*.tar.gz .
    tar -zxf gsl*.tar.gz
    rm -rf gsl*.tar.gz
    cd gsl*
    ./configure
    make -j$(nproc)
    # make test
    $DO make install
}

function del_dir {
    cd ../..
    rm -rf tmp_gsl
}

install_dependency
work_dir
install_gsl
del_dir
