#!/bin/bash

# install ipopt on ubuntu

# ---
# test information
# test passed on docker image ubuntu:18.04
# ---

# after installation, make sure the environment variable is set
# add 'export LD_LIBRARY_PATH=/usr/local/lib' to your ~/.bashrc (Linux)

set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

function apt_install {
    $DO apt update
    $DO apt install -y wget file gcc g++ gfortran git patch wget pkg-config liblapack-dev libmetis-dev unzip
}

function work_dir {
    $DO rm -rf tmp_ipopt
    mkdir tmp_ipopt
    cd tmp_ipopt
}

function install_ipopt {
    # wget https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew -O coinbrew.sh
    cp ../coinbrew.sh .
    # bash coinbrew.sh fetch Ipopt --no-prompt
    cp ../Ipopt.tgz .
    tar -xf Ipopt*
    rm -rf Ipopt.tgz
    cp ../ThirdParty.tgz .
    tar -xf ThirdParty*
    rm -rf ThirdParty.tgz
    work_dir=$(pwd)
    git config --global --add safe.directory ${work_dir}/Ipopt
    git config --global --add safe.directory ${work_dir}/ThirdParty/ASL
    git config --global --add safe.directory ${work_dir}/ThirdParty/Mumps
    git config --global --add safe.directory ${work_dir}/ThirdParty/HSL
    cp ../coinhsl* ./ThirdParty/HSL
    unzip ./ThirdParty/HSL/coinhsl-archive*.zip -d ./ThirdParty/HSL
    rm -rf ./ThirdParty/HSL/coinhsl-archive*.zip
    mv ./ThirdParty/HSL/coinhsl-archive* ./ThirdParty/HSL/coinhsl
    $DO bash coinbrew.sh build Ipopt --prefix=/usr/local --test --no-prompt --verbosity=3
    # $DO bash coinbrew.sh install Ipopt --no-prompt
}

function del_dir {
    cd ..
    $DO rm -rf tmp_ipopt
}

apt_install
work_dir
install_ipopt
del_dir