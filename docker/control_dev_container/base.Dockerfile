# How to build a docker image, which can support my development work for a long time, is always my pain point
# The purpose of this script is to build a docker image based on ubuntu 18.04 to support my development work
# This time I consider using the ARG command in dockerfile to realize the extensibility of docker image

# ros:melodic-ros-core-bionic
# osrf/ros:melodic-desktop-full-bionic
ARG BASE_IMAGE=ros:melodic-ros-core-bionic

FROM $BASE_IMAGE

# Here I made launcher.sh as the entrypoint of the docker image
# And it will switch between default_entrypoint.sh and your custom entrypoint automatically
COPY default_entrypoint.sh launcher.sh /
RUN chmod 777 /default_entrypoint.sh /launcher.sh
ENTRYPOINT [ "/launcher.sh" ]

# Set some environment variables
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Because of some well-known reasons, we can't use curl or wget to download scripts directly in China,
# I put the script directly into Dockerfile
COPY control_dev_install.sh /
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/no-recommends \
    && rm -f ros_entrypoint.sh \
    # --------------------------------------
    # Install curl for downloading scripts
    # && apt-get update \
    # && apt-get install -y curl \
    # --------------------------------------
    # Install dependencies for autonomous control development
    # && curl -O https://raw.githubusercontent.com/sshawn9/my_scripts/master/installers/control_dev_install.sh \
    && bash control_dev_install.sh \
    && rm -f control_dev_install.sh \
    # --------------------------------------
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
