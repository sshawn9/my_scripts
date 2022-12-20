 #!/bin/bash
set -e

if [ -f "software_package/pycharm"* ]; then
	echo "find pycharm package, installing..."
else
	echo "can't find pycharm package, exit"
	exit
fi
sudo tar -zxf software_package/pycharm*.tar.gz -C /usr/local/
echo "alias pycharm=/usr/local/pycharm*/bin/pycharm.sh" >> ~/.bashrc
source ~/.bashrc
