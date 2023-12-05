#!/bin/bash

set -e

docker build -f base.Dockerfile -t sshawn/control_dev:noetic_core_20231205 .
