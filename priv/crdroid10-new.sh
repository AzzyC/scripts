#!/bin/bash

# To make this script easily rewritable for various roms, differences will be stated in variables at the top of the file 
romname=""
rommanifest="https://github.com/crdroidandroid/android.git -b 10.0" # Format should always be <manifesturl>.git -b <branchname>

# This function of statements will reconfigure the time difference before and after desired commands, to make sure that the given time is correct
timecheck () {
	start=( $start )
	starthour="${start[0]}"
	startminute="${start[1]}"
	startsecond="${start[2]}"

	end=( $end )
	endhour="${end[0]}"
	endminute="${end[1]}"
	endsecond="${end[2]}"

	if [[ "$((endhour-starthour))" -lt "0" ]]; then
		endhour="$((24+endhour))"
	fi

	if [[ "$((endminute-startminute))" -lt "0" ]]; then
		endminute="$((60+endminute))"
		endhour="$((endhour-1))"
	fi

	if [[ "$((endsecond-startsecond))" -lt "0" ]]; then
		endsecond="$((60+endsecond))"
		endminute="$((endminute-1))"
	fi
}

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
	sudo apt install -y openjdk-8-jdk lunch # jdk8 required to compile Android 5.0+

	telegram "Android building environment installed"

fi

# Dont attempt to create 'rom' if it already exists - Reduce error noise
if [[ ! -d rom ]]; then
	mkdir rom && cd rom # `cd` will only run, if `mkdir` was successful - Fail-safe for low storage
	repo init -u "$rommanifest" --depth=1 --no-clone-bundle --no-tags -q
	cd .repo/ || return 1
	git clone https://github.com/synt4x93/local_manifests.git -b lineage-17.1 --depth=1 -q
	cd ~
	touch sync
fi

if [[ -e sync ]]; then # If need to sync again after the inital sync, could do so by creating a 'sync' breadcrumb: `touch sync`
	rm sync
	cd ~/rom || return 1

	start="$(date +'%-H %-M %-S')"
	repo sync -c --force-sync -j$(nproc --all) --no-clone-bundle --no-tags --prune --q
	end="$(date +'%-H %-M %-S')"

	timecheck # Use function from first lines to make sure the time doesn't include negatives
	telegram -M "***Sync Time***: ``\`$((endhour-starthour))hour(s) $((endminute-startminute))minute(s) $((endsecond-startsecond))second(s)\```"

	cd ~
	touch build
fi

if [[ -e build ]]; then # Again, to keep it modular when a 'build' breadcrumb is spotted it will begin to `make` again: `touch build`
	rm build
	cd ~/rom || return 1
fi
