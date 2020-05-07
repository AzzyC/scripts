#!/bin/bash

mcfolderid="1s43Sn6h_aoWQ_T2-GpfKs8t7Dy0rMU0n"
scriptstart="$(date +%s)"

cd

if [[ -e backup && -e restore ]]; then
	echo "Both 'backup' and 'restore' file exist"
	echo "Delete one and re-bash the script"
	return 1
fi

if [[ ! -e backup ]]; then
	sudo apt update -y > /dev/null
	sudo apt install unzip zip openjdk-8-jdk-headless -y > /dev/null
fi

if [ -d .gdrive ]; then
	sudo wget -q -nc -O /usr/local/bin/gdrive https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
	sudo chmod a+x /usr/local/bin/gdrive
else
	echo "Not setup GoogleDrive AuthToken"
	return 1
fi

if [[ -e .telegram.sh ]]; then
	sudo wget -q -nc -O /usr/local/bin/telegram https://raw.githubusercontent.com/bluedogerino/jenkins_rom/master/telegram
	sudo chmod a+x /usr/local/bin/telegram
	sudo chmod +x .telegram.sh
else
	echo "Not setup Telegram Tokens"
	return 1
fi

if [ -e backup ]; then
	echo "'backup' file detected"
	rm backup
	mkdir minecraft
	zip -r minecraft_server.zip minecraft_server/ > /dev/null
	sha256sum minecraft_server.zip > minecraft_server.zip.sha256sum
	mv minecraft_server.zip* minecraft
	gdrive upload -p $mcfolderid -r minecraft
	rm -rf minecraft
	scriptend="$(date +%s)"
	telegram "Server backed up in $((scriptend-scriptstart)) second(s)"
fi

if [ -e restore ]; then
	echo "'restore' file detected"
	rm restore
	touch backup
	gdrive download -r $mcfolderid
	mv minecraft/minecraft/minecraft_server.zip* ~

	if [ ! -z "$(sha256sum -c --quiet minecraft_server.zip.sha256sum)" ]; then
		telegram -M "***Action required***: Checksum of server zip did not match!"
		return 1
	fi

	unzip minecraft_server.zip > /dev/null

	if [ ! -z "$(ls minecraft/mods)" ]; then
		telegram "Including new mods into the server:
		$(ls minecraft/mods | sed 's/^/• /')"
		mv minecraft/mods/* minecraft_server/mods
	fi

	rm minecraft_server.zip*
	rm -rf minecraft
	scriptend="$(date +%s)"
	telegram "Server restored in $((scriptend-scriptstart)) second(s)"
	wget -q -nc https://raw.githubusercontent.com/AzzyC/scripts/ReAdScRiPt/priv/mcrunserver.sh
	sudo chmod +x mcrunserver.sh
	. mcrunserver.sh
fi
