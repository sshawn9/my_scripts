#!/bin/bash
set -e


tmp(){
file="testfile"
if [ -f "$file"* ]; then
  echo "fuck1"
  echo "$file"
  echo "$file"*
else
  echo "fuck2"
fi


#awk '{printf $1 + $2}'
echo "test bash end"
}

haha(){
echo "alias clion=/usr/local/clion*/bin/clion.sh" >> ~/.bashrc
ha1=$(find ~ -name 111*)
ha2=($ha1)
echo -e ${#ha2[*]}
echo -e ${ha2[0]}
echo -e ${ha2[1]}
echo -e ${ha2[2]}
echo -e ${ha2[3]}
echo -e ${ha2[4]}
echo -e ${ha2[5]}
echo -e ${ha2[6]}
echo -e ${ha2[7]}
echo -e ${ha2[8]}
echo -e ${ha2[9]}
echo -e ${ha2[10]}
echo -e ${ha2[11]}
echo -e ${ha2[12]}
echo -e ${ha2[13]}
echo -e ${ha2[14]}
echo -e ${ha2[15]}
echo -e ${ha2[16]}
echo -e ${ha2[17]}
echo -e ${ha2[18]}
echo -e ${ha2[19]}
}

#set -e

folder=~/
target="CLion*"
file_path=""
install_path=$HOME/softwares/
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
tar -zxf $file_path -C $install_path
echo "alias clion=$install_path/clion*/bin/clion.sh" >> ~/.bash_aliases
source ~/.bashrc

	
