#!/bin/bash

# install protobuf on ubuntu
# only install protobuf cpp

# ---
# test information
#
# ---

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

protobuf_url=https://github.com/protocolbuffers/protobuf/releases/download/v21.5/protobuf-all-21.5.tar.gz

function install_dependency {
    $DO apt update
    $DO apt-get -y install autoconf automake libtool curl make g++ unzip wget
}

function work_dir {
    $DO rm -rf tmp_protobuf
    mkdir tmp_protobuf
    cd tmp_protobuf
}

function install_protobuf {
    # wget protobuf_url -O source_protobuf.tar.gz
    cp ../protobuf*.tar.gz .
    tar -xf protobuf*.tar.gz
    rm -rf protobuf*.tar.gz
    cd protobuf*
    ./configure
    make -j$(nproc) # $(nproc) ensures it uses all cores for compilation
    make check
    $DO make install
    $DO ldconfig # refresh shared library cache.
}

function del_dir {
    cd ../..
    rm -rf tmp_protobuf
}

install_dependency
work_dir
install_protobuf
del_dir
