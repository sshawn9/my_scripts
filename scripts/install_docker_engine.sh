#!/bin/bash

# install docker engine on ubuntu

# ---
# test information
#
# ---

function install_docker {
    sudo apt update
    sudo apt install -y curl uidmap
    sudo curl -fsSL https://get.docker.com | bash
}

function post_installation {
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
}

install_docker
post_installation