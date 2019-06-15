#!/bin/bash
set -e

if [ -f "software_package/CLion"* ]; then
	echo "find clion, start installing..."
else
	echo "can't find clion package, exit"
	exit
fi
#sudo cp software_package/CLion*.tar.gz /usr/local/
tar -zxf software_package/CLion*.tar.gz -C $HOME/softwares/
echo "alias clion=$HOME/softwares/clion*/bin/clion.sh" >> ~/.bashrc
source ~/.bashrc
