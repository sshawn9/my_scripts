## refer to https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions

#!/bin/bash
set -e

ver="8.x"
#ver="10.x"

if [ $ver = "8.x" ]; then
	website="https://deb.nodesource.com/setup_8.x"
fi
if [ $ver = "10.x" ]; then
	website="https://deb.nodesource.com/setup_10.x"
fi

#echo $website

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
