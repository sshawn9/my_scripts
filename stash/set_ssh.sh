#!/bin/bash
set -e

sudo apt install xsel -y

# replace with your default email here
email="2120170431@bit.edu.cn"

if [ -n "$1" ]; then
	email=$1
else
	echo "use default email"
fi
echo "email is : $email"

ssh_folder="$HOME/.ssh"


folder_check(){
	folder_check_result=false
	if [ -d $ssh_folder ]; then
		#echo "$ssh_folder already exist"
		if [ "`ls -A $ssh_folder`" = "" ]; then
			#echo "$ssh_folder is empty"
			rm -rf $ssh_folder
			echo "delete empty folder: $ssh_folder"
			folder_check_result=true
		else
			echo ""
			echo "$ssh_folder is not empty, it contains resources as follows:"
			ls -A $ssh_folder
			echo ""
			folder_check_result=false
		fi
	else
		folder_check_result=true
	fi
}

set_ssh(){
	ssh-keygen -t rsa -b 4096 -C "$email" -f $HOME/.ssh/id_rsa -N ""
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa
	cat $ssh_folder/id_rsa.pub | xsel --clipboard
	xdg-open "https://github.com/settings/ssh/new" >> /dev/null
}

main(){
	folder_check
	if ! $folder_check_result; then
		echo "folder_check error, terminate"
		return
	fi
	set_ssh
}

main
