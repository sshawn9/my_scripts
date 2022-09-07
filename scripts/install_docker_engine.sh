#!/bin/bash

# install docker engine on ubuntu

# ---
# test information
#
# ---

function install_docker {
    apt update
    apt install -y curl uidmap
    curl -fsSL https://get.docker.com | bash
}

function post_installation {
    groupadd docker
    usermod -aG docker $USER
    newgrp docker
}

install_docker
post_installation