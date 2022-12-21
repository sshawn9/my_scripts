#!/bin/bash

# set ssh in docker container for remote building and remote development
# this scripts must run in container which you want to set ssh
# make sure your container already have origin .bashrc file (ignore this now)

# tips:
# ~/.profile simply execute ~/.bashrc if you use bash


# ---
# test information
# 
# ---

# refer to https://github.com/JetBrains/clion-remote/blob/master/Dockerfile.remote-cpp-env


set -e

# check if root
DO="sudo"
if [ $UID -eq 0 ];then DO="";fi
# echo $DO

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
echo "tzdata tzdata/Areas select Asia" | debconf-set-selections
echo "tzdata tzdata/Zones/Asia select Shanghai" | debconf-set-selections

$DO apt update
$DO apt install tzdata -y
$DO apt install -y ssh openssh-server build-essential gcc g++ gdb clang make ninja-build cmake autoconf automake locales-all dos2unix rsync tar python

$DO echo 'LogLevel DEBUG2' >> /etc/ssh/sshd_config
$DO echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
$DO echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
# $DO echo 'Subsystem sftp /usr/lib/openssh/sftp-server' >> /etc/ssh/sshd_config
$DO echo 'X11Forwarding yes' >> /etc/ssh/sshd_config
$DO echo 'PermitUserEnvironment yes' >> /etc/ssh/sshd_config
$DO echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config
$DO mkdir /run/sshd
sed -i '1i. ~/.bash_env' ~/.bashrc
touch ~/.bash_env
