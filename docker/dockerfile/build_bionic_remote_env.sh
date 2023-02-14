#!/bin/bash

set -e
rm -rf build
mkdir build
cp -r ../../installers/* build
cp -r ../../utilities/* build
echo "#!/bin/bash" >> build/build.sh
echo "set -e" >> build/build.sh
echo "bash change_apt_source.sh" >> build/build.sh
echo "bash change_ros_source.sh" >> build/build.sh
echo "bash ssh_for_remote_dev.sh" >> build/build.sh
echo "bash install_dependencies.sh" >> build/build.sh

docker build -f bionic_remote_env.Dockerfile -t sshawn/bionic_remote_env:1.0 .
rm -rf build
