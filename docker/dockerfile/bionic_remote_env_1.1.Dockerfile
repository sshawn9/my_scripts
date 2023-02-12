FROM sshawn/bionic_remote_env:1.0
COPY build /tmp
WORKDIR /tmp
RUN bash build.sh \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/workspace \
    && rm -rf /tmp/*
WORKDIR /root/workspace
EXPOSE 22
