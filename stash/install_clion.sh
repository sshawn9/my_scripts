 #!/bin/bash
set -e

if [ -f "software_package/CLion"* ]; then
	echo "find clion package, installing..."
else
	echo "can't find clion package, exit"
	exit
fi
#sudo cp software_package/CLion*.tar.gz /usr/local/
sudo tar -zxf software_package/CLion*.tar.gz -C /usr/local/
echo "alias clion=/usr/local/clion*/bin/clion.sh" >> ~/.bashrc
source ~/.bashrc
