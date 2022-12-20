#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

chores(){
	gsettings set org.gnome.gedit.preferences.encodings candidate-encodings "['GB18030', 'GB2312', 'GBK', 'UTF-8', 'CURRENT', 'ISO-8859-15', 'UTF-16']"
}

check_apt_key(){
	if [ -z "$(apt-key list | grep Sublime)" ]; then
		echo "The apt-key of Sublime not add successfully!"
		echo "Please add it manually first using the command as bellow:"
		echo "wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -"
		exit
	fi
}

install_sublime(){
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	check_apt_key
	sudo apt-get install -y apt-transport-https
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo apt-get update
	sudo apt-get install -y sublime-text
}

sublime_fix(){
	sudo apt-get install -y libgtk2.0-dev
	sudo cp $SCRIPT_DIR/libsublime-imfix.so /opt/sublime_text/
	sudo sed -i 's/exec/LD_PRELOAD=\/opt\/sublime_text\/libsublime-imfix.so &/' /usr/bin/subl
	sudo mv /usr/share/applications/sublime_text.desktop /usr/share/applications/sublime_text.desktop.bak
	touch ~/tmp_sublime_text_desktop
	echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Comment=Sophisticated text editor for code, markup and prose
Exec=bash -c \"LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text %F\"
Terminal=false
MimeType=text/plain;
Icon=sublime-text
Categories=TextEditor;Development;
StartupNotify=true
Actions=Window;Document;

[Desktop Action Window]
Name=New Window
Exec=bash -c \"LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text -n\"
OnlyShowIn=Unity;

[Desktop Action Document]
Name=New File
Exec=bash -c \"LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text --command new_file\"
OnlyShowIn=Unity;" >> ~/tmp_sublime_text_desktop
	sudo mv ~/tmp_sublime_text_desktop /usr/share/applications/sublime_text.desktop
	sudo chmod +x /usr/share/applications/sublime_text.desktop
}

main(){
	chores
	install_sublime
	sublime_fix
}

main
