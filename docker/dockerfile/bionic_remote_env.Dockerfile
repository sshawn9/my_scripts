FROM osrf/ros:melodic-desktop-full
COPY build /tmp
WORKDIR /tmp
RUN bash build.sh \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/workspace \
    && echo "#!/bin/bash" >> /entrypoint.sh \
    && echo "set -e" >> /entrypoint.sh \
    && echo "service ssh start" >> /entrypoint.sh \
    && echo 'exec "$@"' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    && echo 'source "/opt/ros/melodic/setup.bash"' >> ~/.bash_env \
    && echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bash_env \
    && echo 'export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bash_env \
    && rm -rf /tmp/*
WORKDIR /root/workspace
EXPOSE 22
