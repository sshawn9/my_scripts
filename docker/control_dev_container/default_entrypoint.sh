#!/bin/bash

set -e

source /opt/ros/$ROS_DISTRO/setup.bash

if [ $ROS_VERSION == "1" ]; then
    if [ -f /msg_ws/devel/setup.bash ]; then
        source /msg_ws/devel/setup.bash
    fi
fi
if [ $ROS_VERSION == "2" ]; then
    if [ -f /msg_ws/install/setup.bash ]; then
        source /msg_ws/install/setup.bash
    fi
fi

exec "$@"
