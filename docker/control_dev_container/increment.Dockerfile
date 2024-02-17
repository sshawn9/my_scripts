# How to build a docker image, which can support my development work for a long time, is always my pain point
# The purpose of this script is to build a docker image based on ubuntu 18.04 to support my development work
# This time I consider using the ARG command in dockerfile to realize the extensibility of docker image

ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL [ "/bin/bash", "-c" ]

RUN apt-get update \
    && apt-get install -y libzmq3-dev htop libtbb-dev \
    # --------------------------------------
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
