#!/bin/bash

# install docker engine on ubuntu

# ---
# test information
# test failed on ubuntu16.04, but install binaries works, refer to: https://docs.docker.com/engine/install/binaries/
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