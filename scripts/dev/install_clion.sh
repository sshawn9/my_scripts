#!/bin/bash
set -e

# make sure you know what this script will do
# put this script into the clion package folder

folder=~/Downloads
target="CLion*"
file_path=""
install_path=$HOME/softwares

echo "search folder: $folder"
echo "search file: $target"
echo "install path: $install_path"

tmp=$(find $folder -name $target)
suspects=($tmp)
suspects_num=${#suspects[*]}

if [ $suspects_num == 0 ]
then
	echo "can't find any $target package, do check"
	exit
fi

if [ $suspects_num -gt 1 ]
then

	### TODO
	echo "file more than 1, exit because this script is not complete"
	exit
	###

	echo "find related file num: $suspects_num"
	tmpi=0
	echo 111
	for i in ${suspects[*]}
	do
		let tmpi++ # if set -e, error here
		echo "$tmpi) $i"
	done
	
	echo -e "input num 1-$suspects_num to choose a file and install, or 'q' for quit:"
	read num_choose
	if [ $num_choose == "q" ]
		then exit
	fi
	
	if [ $num_choose -gt 0 ]
	then
		echo "illegal input, exit"
		exit
	fi
fi

file_path=${suspects[0]}

if [ ! -d $install_path ]
then
	mkdir -p $install_path
fi

tar -zxf $file_path -C $install_path
echo "alias clion=$install_path/clion*/bin/clion.sh" >> ~/.bash_aliases
source ~/.bashrc
