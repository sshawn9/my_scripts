#!/bin/bash

set -e

source /opt/ros/$ROS_DISTRO/setup.bash
source /msg_ws/devel/setup.bash
exec "$@"
