#!/bin/bash

# install cppad on ubuntu

# ---
# test information
#
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

CppAD_URL="https://github.com/coin-or/CppAD/archive/20220000.4.tar.gz"

function apt_install {
    $DO apt update
    $DO apt install -y wget cmake g++
}

function work_dir {
    $DO rm -rf tmp_cppad
    mkdir tmp_cppad
    cd tmp_cppad
}

function install_cppad {
    # wget $CppAD_URL -O cppad.tar.gz
    cp ../CppAD*.tar.gz .
    tar -xf CppAD*.tar.gz
    rm -rf CppAD*.tar.gz
    cd CppAD*
    mkdir build
    cd build
    cmake ..
    make check
    $DO make install
}

function del_dir {
    cd ../../..
    rm -rf tmp_cppad
}

apt_install
work_dir
install_cppad
del_dir
