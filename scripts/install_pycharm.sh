#!/bin/bash
set -e

if [ -f "software_package/pycharm"* ]; then
	echo "find pycharm, start installing..."
else
	echo "can't find pycharm package, exit"
	exit
fi
#sudo cp software_package/CLion*.tar.gz /usr/local/
tar -zxf software_package/pycharm*.tar.gz -C $HOME/softwares/
echo "alias pycharm=$HOME/softwares/pycharm*/bin/pycharm.sh" >> ~/.bashrc
source ~/.bashrc
