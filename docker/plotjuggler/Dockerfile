ARG ROS_DISTRO

FROM ros:$ROS_DISTRO-ros-core

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/no-recommends \
    && apt-get update \
    && apt-get install --fix-missing -y ros-$ROS_DISTRO-plotjuggler-ros \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash", "-c", "sleep 3 && rosrun plotjuggler plotjuggler"]
