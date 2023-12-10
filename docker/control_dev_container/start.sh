docker run -it \
           -v ~:/star \
           -v ~/Documents/GitHub:/GitHub \
           -v ~/Documents/Github/autonomous:/autonomous \
           --name control_dev \
           --hostname control_dev \
           sshawn/control_dev:noetic_msgs_20231205 \
           bash