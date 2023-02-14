FROM sshawn/bionic_remote_env:1.2
COPY build /opt
COPY tmp_customization_bit.sh /opt/msg_ws
COPY clion_remote_env_entrypoint.sh /
WORKDIR /opt/msg_ws
RUN bash tmp_customization_bit.sh
WORKDIR /root/workspace
EXPOSE 22
ENTRYPOINT [ "/clion_remote_env_entrypoint.sh" ]