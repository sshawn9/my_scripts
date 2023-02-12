#!/bin/bash

set -e
rm -rf build
mkdir -p build/packages


cp -r ../../installers/install_osqp.sh build
cp -r ../../utilities/packages/osqp* build/packages
echo "#!/bin/bash" >> build/build.sh
echo "set -e" >> build/build.sh
echo "bash install_osqp.sh" >> build/build.sh

docker build -f bionic_remote_env_1.1.Dockerfile -t sshawn/bionic_remote_env:1.1 .
rm -rf build
