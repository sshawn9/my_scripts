#!/bin/bash

set -e

docker build -f bionic_remote_env_1.2.Dockerfile -t sshawn/bionic_remote_env:1.2 .
