#!/bin/bash

# docker run -itd \
# 	-v /etc/localtime:/etc/localtime:ro \
# 	-v /tmp/.X11-unix:/tmp/.X11-unix \
# 	-e DISPLAY=unix$DISPLAY \
# 	-e GDK_SCALE \
# 	-e GDK_DPI_SCALE \
# 	--privileged \
# 	--device=/dev/dri:/dev/dri \
# 	-p 2345:22 \
# 	-v $HOME/workspace:/root/external \
# 	--name test \
# 	ubuntu:22.04

# docker run -itd \
# 	-v /etc/localtime:/etc/localtime:ro \
# 	--privileged \
# 	-v $HOME/workspace:/root/external \
# 	--name test \
# 	ubuntu:22.04

# docker run -itd \
# 	-v $HOME/workspace:/root/external \
#     -p 2222:22 \
# 	--name clion-dev-env \
# 	sshawn/ubuntu18-dev-env:0.0.7

# test scripts for 
# change apt source
# ipopt
# cppad
# ceres
# protobuf

# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test1 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test2 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test3 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test4 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test5 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test6 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test7 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test8 \
# 	ubuntu:18.04
# docker run -itd \
# 	-v $HOME/workspace/my_scripts/scripts:/root/external \
# 	--name test9 \
# 	ubuntu:18.04

# docker run -itd \
# 	-v $HOME/workspace:/root/external \
# 	--name desktop_test \
# 	sshawn/ubuntu18-dev-env:0.0.7

# docker run -itd -p 35729:35729 -p 4000:4000 -v $HOME/workspace/sshawn9.github.io:/jekyll --name jekyll jekyll/jekyll
docker run -itd -p 3333:22 -v $HOME/workspace/my_scripts:/root --name utest ubuntu:18.04