#!/bin/bash

set -e

docker build -f msgs.Dockerfile -t sshawn/control_dev:noetic_msgs_20231205 .
