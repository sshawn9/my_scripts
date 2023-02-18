#!/bin/bash

docker run -itd \
	-v /etc/localtime:/etc/localtime:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=unix$DISPLAY \
	-e GDK_SCALE \
	-e GDK_DPI_SCALE \
	--privileged \
	--device=/dev/dri:/dev/dri \
	--hostname=star-docker \
	-p 2222:22 \
	-v $HOME/workspace:/root/workspace \
	-v $HOME/autonomous:/root/autonomous \
	--name remote_env \
	sshawn/custom_bit_bionic_remote_env:1.2 \
	/bin/bash
