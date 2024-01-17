FROM sshawn/control_dev:humble_msgs_20240113
SHELL [ "/bin/bash", "-c" ]
RUN apt update \
    && apt install -y git \
    && mkdir -p /carla_ws/src \
    && cd /carla_ws/src \
    && git clone https://github.com/carla-simulator/ros-carla-msgs.git \
    && cd .. \
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && colcon build \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY default_entrypoint.sh /default_entrypoint.sh
ENTRYPOINT ["/default_entrypoint.sh"]