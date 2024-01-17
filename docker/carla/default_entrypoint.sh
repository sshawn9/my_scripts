#!/bin/bash

set -e

source /opt/ros/$ROS_DISTRO/setup.bash
source /msc_ws/install/setup.bash
source /carla_ws/install/setup.bash

exec "$@"
