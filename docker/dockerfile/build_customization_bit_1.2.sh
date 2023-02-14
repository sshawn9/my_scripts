#!/bin/bash
# multi-stage should be considered in the future

set -e

# the script running in the image build process
rm -f tmp_customization_bit.sh
cat>tmp_customization_bit.sh<<EOF
#!/bin/bash
chmod +x /clion_remote_env_entrypoint.sh
source /opt/ros/melodic/setup.bash
catkin build
cd ..
chmod -R 777 msg_ws

EOF
chmod +x tmp_customization_bit.sh

# the customized entrypoint
rm -f clion_remote_env_entrypoint.sh
cat>clion_remote_env_entrypoint.sh<<EOF
#!/bin/bash

# using for clion toolchains with docker 
# set this file to the entrypoint in the container settings

# here are some tips for setting docker as the toolchain in clion
# docker container settings
# port bindings
# -p 2222:22 # not sure
# volume bingings
# -v ~/workspace:/root/workspace
# while I have some tries, it seems not easy to maintain ros custom msgs stored in binded volumes,
# so I make a custom image to depoly custom msgs in the image

set -e

source "/opt/ros/\$ROS_DISTRO/setup.bash"

if [ -e "/opt/msg_ws/devel/setup.bash" ]; then
    source "/opt/msg_ws/devel/setup.bash"
fi

exec "\$@"

EOF
chmod +x clion_remote_env_entrypoint.sh


rm -rf build
mkdir build

cp -r ~/workspace/gitee/003-msgs/msg_ws build

docker build -f customization_bit_1.2.Dockerfile -t sshawn/custom_bit_bionic_remote_env:1.2 .
rm -rf build
rm tmp_customization_bit.sh
rm clion_remote_env_entrypoint.sh
