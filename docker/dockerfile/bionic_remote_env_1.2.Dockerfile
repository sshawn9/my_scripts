FROM sshawn/bionic_remote_env:1.1
RUN apt update \
    && apt install python-catkin-tools -y 
WORKDIR /root/workspace
EXPOSE 22
