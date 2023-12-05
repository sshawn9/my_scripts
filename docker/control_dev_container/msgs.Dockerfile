FROM sshawn/control_dev:noetic_core_20231205
SHELL ["/bin/bash", "-c"]
COPY default_entrypoint.sh /
RUN chmod 777 /default_entrypoint.sh
ENTRYPOINT ["/default_entrypoint.sh"]
#ros-melodic-tf 
#RUN apt-get install  --fix-missing -y ros-melodic-cv-bridge
RUN apt-get update \
    && apt-get install --fix-missing -y python3-catkin-tools ros-$ROS_DISTRO-tf ros-$ROS_DISTRO-cv-bridge \
    && git clone https://github.com/autonomous-group/msg_ws.git \
    && cd msg_ws \
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && catkin build \
    && rm -rf src .git* \
    && cd .. \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
