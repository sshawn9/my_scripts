#!/bin/bash

set -e

docker build -f base.Dockerfile -t sshawn/control_dev:base_20230817 .
