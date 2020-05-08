#!/bin/bash

cd ~ # Begin script in home directory

if [[ ! -d buildenv ]]; then # Only bash this part of script once; directory used as a breadcrumb

	# Use HTTP Telegram to notify script progress AFK
	if [[ -e .telegram.sh ]]; then
		sudo wget -q -nc -O /usr/local/bin/telegram https://raw.githubusercontent.com/fabianonline/telegram.sh/master/telegram
		sudo chmod a+x /usr/local/bin/telegram
		sudo chmod +x .telegram.sh
	else
		printf "\nNot setup Telegram Tokens\n"
		return 1
	fi

	# Use CLI Google Drive to upload files
	if [ -d .gdrive ]; then
		sudo wget -q -nc -O /usr/local/bin/gdrive https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
		sudo chmod a+x /usr/local/bin/gdrive
	else
		echo "Not setup GoogleDrive AuthToken"
		return 1
	fi

	# Skip git prompts
	git config --global user.name AzzyC
	git config --global user.email azmath2000@gmail.com
	git config --global color.ui true

	# Install Android building environment packages
	git clone https://github.com/akhilnarang/scripts.git build_env --depth=1 # `--depth=1` No time wasting fetching commit history
	sudo chmod +x build_env/setup/android_build_env.sh
	. build_env/setup/android_build_env.sh
	sudo apt install -y openjdk-8-jdk # jdk8 required to compile Android 5.0+

	telegram "Android building environment installed"

fi

# Dont attempt to create 'rom' if it already exists - Reduce error noise
if [[ ! -d rom ]]; then
	mkdir rom && cd rom # `cd` will only run, if `mkdir` was successful - Fail-safe for low storage
	repo init -u https://github.com/crdroidandroid/android.git -b 10.0 --depth=1 --no-clone-bundle --no-tags -q
	cd .repo/ || return 1
	git clone https://github.com/synt4x93/local_manifests.git -b lineage-17.1 --depth=1 -q
	cd ~
	touch sync # Leave breadcrumb so that `repo sync` runs; make `repo sync` modular, if need to `repo sync` again
fi

if [[ -e sync ]]; then
	
fi