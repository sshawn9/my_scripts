#!/bin/bash
set -e


if [ -f "software_package/nautilus_nutstore_amd64"* ]; then
	echo "haha"
else
	wget -P software_package/ https://www.jianguoyun.com/static/exe/installer/ubuntu/nautilus_nutstore_amd64.deb
fi

sudo gdebi software_package/nautilus_nutstore_amd64*

