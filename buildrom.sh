#!/bin/bash

lineage10 () {
	romname="lineage-17.1"
	rommanifest=""

}

crdroid10 () {
	romname="crDroidAndroid-10.0"
	rommanifest=""

}

if [[ "$1" != "quiet" ]]; then

	if [[ "$1" =~ ^(lineage10|crdroid10)$ ]]
	then
		"$1" # Use the variable to call for the function, rather than specifying each time
	fi

	while [[ ! "$changerom" =~ ^(Y|y|N|n)$ ]]
	do
		printf '%s\n' "Selected ROM: $romname" "Do you want to change? (y/N)" ""
		read -n 2 -r -t 20 changerom
	done

	if [[ "$changerom" =~ ^[Yy]$ ]]; then
		unset changerom
		unset romname
	fi	

	if [[ -z "$romname" ]]; then
		PS3='Please enter your number choice: '
		roms=("LineageOS (10)" "crDroid (10)" "Quit")
		select rom in "${roms[@]}"
		do
		    case $rom in
		        "LineageOS (10)")
					lineage10
		            ;;
		        "crDroid (10)")
					crdroid10
		            ;;
		        "Quit")
		            break
		            ;;
		        *)
					printf '%s\n' "" "You did not choose any of the options: '$REPLY'. Try again:" ""
					;;
		    esac
		done
	fi

fi

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

env () {
	if [[ ! -d buildenv ]]; then # Only bash this part of script once; directory used as a breadcrumb

		# Use HTTP Telegram to notify script progress AFK
		if [[ -e .telegram.sh ]]; then
			sudo wget -q -nc -O /usr/local/bin/telegram https://raw.githubusercontent.com/fabianonline/telegram.sh/master/telegram
			sudo chmod a+x /usr/local/bin/telegram
			sudo chmod +x .telegram.sh
		else
			printf "\nNot setup Telegram Tokens\n"
		fi

		# Use CLI Google Drive to upload files
		if [ -d .gdrive ]; then
			sudo wget -q -nc -O /usr/local/bin/gdrive https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
			sudo chmod a+x /usr/local/bin/gdrive
		else
			printf "Not setup GoogleDrive AuthToken"
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
}

# Dont attempt to create '"$romname"' if it already exists - Reduce error noise
init () {

	cd ~

	if [[ ! -d "$romname" ]]; then
		mkdir "$romname"
	else
		cd "$romname"
		repo init -u "$rommanifest" --depth=1 --no-clone-bundle --no-tags -q
		cd .repo || return
		git clone https://github.com/synt4x93/local_manifests.git -b lineage-17.1 --depth=1 -q
	fi
}

sync () {
	cd ~/"$romname" || return

	if [[ -d .repo ]]; then

		start="$(date +'%-H %-M %-S')"
		repo sync -c --force-sync -j$(nproc --all) --no-clone-bundle --no-tags --prune --q
		end="$(date +'%-H %-M %-S')"

		timecheck # Use `timecheck` function to make sure the time is correctly formatted
		telegram -M "***Sync Time***: ``\`$((endhour-starthour))hour(s) $((endminute-startminute))minute(s) $((endsecond-startsecond))second(s)\```"
	fi
}

build () {
	cd ~/"$romname" || return

	if [[ -d .repo ]]; then
		#command
	fi
}

#printf '%s\n' "" # Temp Comment: Copy & Paste 