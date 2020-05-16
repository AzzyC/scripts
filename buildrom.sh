#!/bin/bash

lineage10 () {
	romid="lineage10"
	romname="lineage-17.1"
	rommanifest="https://github.com/LineageOS/android.git -b lineage-17.1"
	lunchname="lineage"
}

crdroid10 () {
	romid="crdroid10"
	romname="crDroidAndroid-10.0"
	rommanifest="https://github.com/crdroidandroid/android.git -b 10.0"
	lunchname="lineage"
}

# Function supports filtering Users' input for words that dont resemble device names
filterdevicearray () {
	if [[ "${readdevice[@]}" =~ "starlte" ]]; then
		devices+=('starlte')
	fi

	if [[ "${readdevice[@]}" =~ "star2lte" ]]; then
		devices+=('star2lte')
	fi

	if [[ "${readdevice[@]}" =~ "crownlte" ]]; then
		devices+=('crownlte')
	fi
}

# Calculate and print the accurate time for commands
timecheck () {
	statetime="$(printf '%02dh:%02dm:%02ds' $(( (end-start) / 3600 )) $(( ( (end-start) % 3600) / 60 )) $(( (end-start) % 60 )) )"
}

buildenv () {

	# Use HTTP Telegram to notify script progress AFK
	if [[ -e .telegram.sh ]]; then
		sudo wget -q -nc -O /usr/local/bin/telegram https://raw.githubusercontent.com/fabianonline/telegram.sh/master/telegram
		sudo chmod a+x /usr/local/bin/telegram
	else
		printf "\nNot setup Telegram Tokens\n"
	fi

	# Use CLI Google Drive to upload files
	if [[ -d .gdrive ]]; then
		sudo wget -q -nc -O /usr/local/bin/gdrive https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
		sudo chmod a+x /usr/local/bin/gdrive
	else
		printf "Not setup GoogleDrive AuthToken"
	fi

	# Skip git config prompts
	git config --global user.name AzzyC
	git config --global user.email azmath2000@gmail.com
	git config --global color.ui true

	# Install Android building environment packages
	git clone https://github.com/akhilnarang/scripts.git build_env --depth=1
	sudo chmod +x build_env/setup/android_build_env.sh
	. build_env/setup/android_build_env.sh
	sudo apt install -y openjdk-8-jdk lunch # jdk8 required to compile Android 5.0+

	printf '%s\n' "" "Android building environment established at $(date +%T)" ""
	telegram "Android building environment established"
}

init () {

	cd ~

	if [[ ! -d "$romname" ]]; then
		mkdir "$romname"
	else

	cd "$romname"
	repo init -u "$rommanifest" --depth=1 --no-clone-bundle --no-tags -q
	cd .repo || return
	git clone https://github.com/synt4x93/local_manifests.git -b lineage-17.1 --depth=1 -q

	printf '%s\n' "" "$romname manifest repo initialised at $(date +%T)" ""
	telegram "$romname manifest repo initialised"

}

romsync () {
	cd ~/"$romname" || return

	if [[ -d .repo ]]; then

		start="$(date +%s)"
		repo sync -c --force-sync -j$(nproc --all) --no-clone-bundle --no-tags --prune --q
		end="$(date +%s)"

		timecheck

		printf '%s\n' "" "Sync Time: $statetime " ""
		telegram -M "***Sync Time***: ``\`$statetime\```"

	fi
}

configtree () {
	"$romid"
}

build () {
	cd ~/"$romname" || return
	. build/envsetup.sh

	# Now using aforementioned 'devices' array
	if [[ "${devices[@]}" =~ "starlte" ]]; then
		lunch "$lunchname"_starlte-userdebug

		start="$(date +%s)"
		make bacon -j$(nproc --all) 2>&1 | tee ~/make_starlte.txt
		end="$(date +%s)"

		awk '/FAILED:/,EOF' ~/make_starlte.txt ~/fail_starlte.txt # Trim make log down to just show fail

		timecheck

		if [[ -e ~/"$romname"/out/target/product/starlte/"$romname"*.zip ]]; then
			return
			telegram ~/fail_starlte.txt "Uh oh.. build failed after $statetime"
			printf '%s\n' "" "" ""
			cat ~/fail_starlte.txt
			printf '%s\n' "" "Build failed after $statetime" "See ~/fail_starlte.txt for fail log" ""
		fi

	fi

	if [[ "${devices[@]}" =~ "star2lte" ]]; then
		lunch "$lunchname"_star2lte-userdebug

		start="$(date +%s)"
		make bacon -j$(nproc --all) 2>&1 | tee ~/make_star2lte.txt
		end="$(date +%s)"

		awk '/FAILED:/,EOF' ~/make_star2lte.txt ~/fail_star2lte.txt

		timecheck

		if [[ -e ~/"$romname"/out/target/product/star2lte/"$romname"*.zip ]]; then
			return
			telegram ~/fail_star2lte.txt "Uh oh.. build failed after $statetime"
			printf '%s\n' "" "" ""
			cat ~/fail_star2lte.txt
			printf '%s\n' "" "Build failed after $statetime" "See ~/fail_star2lte.txt for fail log" ""
		fi

	fi

	if [[ "${devices[@]}" =~ "crownlte" ]]; then
		lunch "$lunchname"_crownlte-userdebug

		start="$(date +%s)"
		make bacon -j$(nproc --all) 2>&1 | tee ~/make_crownlte.txt
		end="$(date +%s)"

		awk '/FAILED:/,EOF' ~/make_crownlte.txt ~/fail_crownlte.txt

		timecheck

		if [[ -e ~/"$romname"/out/target/product/crownlte/"$romname"*.zip ]]; then
			return
			telegram ~/fail_crownlte.txt "Uh oh.. build failed after $statetime"
			printf '%s\n' "" "" ""
			cat ~/fail_crownlte.txt
			printf '%s\n' "" "Build failed after $statetime" "See ~/fail_crownlte.txt for fail log" ""
		fi

	fi
}

# Function which brings all modular functions together, to make complete ROM
totalbuild () {
	buildenv
	init
	romsync
	configtree
	build
}

# If User sources script instead of executing, these variables turn global and could still have value. Unset to some parts of the script being skipped over
unset romname
unset devices
unset readdevice

# If script is sourced, can use 'quiet' flag to only pull functions from script without prompts. Flag futile if script executed
if [[ "$1" != "quiet" ]]; then

	if [[ "$1" =~ ^(lineage10|crdroid10)$ ]] # Can only choose one ROM, so pipe in brackets to seperate different ROM options
	then
		"$1" # Use the postional parameter to call for the corresponding ROM function, saves condition flooding
	fi

	if [[ ! -z "$2" ]]; then # First device name should be stated from second parameter

		if [[ "$@" =~ "starlte" ]] || [[ "$@" =~ "star2lte" ]] || [[ "$@" =~ "crownlte" ]]; then

			# If postional array contains device names, transport each stated device into the 'devices' array. To identify which devices to build
			if [[ "$@" =~ "starlte" ]]; then
				devices+=('starlte')
			fi

			if [[ "$@" =~ "star2lte" ]]; then
				devices+=('star2lte')
			fi

			if [[ "$@" =~ "crownlte" ]]; then
				devices+=('crownlte')
			fi
		else
			while [[ ! "${readdevice[@]}" =~ "starlte" ]] && [[ ! "${readdevice[@]}" =~ "star2lte" ]] && [[ ! "${readdevice[@]}" =~ "crownlte" ]]
			do
				printf '%s\n' "" "Typo made stating a device name. Try again:" "" "Which device(s) do you want to build the $romname for? (starlte/star2lte/crownlte)"
				printf "Device(s): "
				read -r -a readdevice
			done

			filterdevicearray
		fi
	fi

	if [[ ! -z "$romname" ]] && [[ ! -z "$devices" ]]; then

		# Stating '-y' in command-line can skip prompt, if certain with the ROM and devices stated
		if [[ ! "$@" =~ "-y" ]]; then

			while [[ ! "$changesetup" =~ ^(Y|y|N|n)$ ]]
			do
				printf '%s\n' "" "Selected ROM: $romname" "" "Selected Device(s): ${devices[0]} ${devices[1]} ${devices[2]}"
				printf "Would you like to change any of the setup? (y/N): "
				read -n 2 -r changesetup
				printf '%s\n' ""
			done

			if [[ "$changesetup" =~ ^[Yy]$ ]]; then
				unset romname
				unset devices
				unset readdevice
			fi
			unset changesetup
		fi
	fi

	if [[ ! -n "$romname" ]]; then # If no stated ROM in command-line OR changed setup, then menu
		PS3='Please enter your number choice: '
		roms=("LineageOS (10)" "crDroid (10)" "Quit")
		select rom in "${roms[@]}"
		do
			case $rom in
				"LineageOS (10)")
					lineage10
					break
					;;
				"crDroid (10)")
					crdroid10
					break
					;;
				"Quit")
					return
					;;
				*)
					printf '%s\n' "" "You did not choose any of the options: '$REPLY'. Try again:" ""
					;;
			esac
		done

		unset REPLY
	fi

	# If no stated devices in command-line OR changed setup, this final loop to state devices 
	while [[ ! "${readdevice[@]}" =~ "starlte" ]] && [[ ! "${readdevice[@]}" =~ "star2lte" ]] && [[ ! "${readdevice[@]}" =~ "crownlte" ]]
	do
		printf '%s\n' "" "Which device(s) do you want to build the $romname for? (starlte/star2lte/crownlte)"
		printf "Device(s): "
		read -r -a readdevice
	done

	filterdevicearray

	printf '%s\n' "" "Final setup: $romname for ${devices[0]} ${devices[1]} ${devices[2]}" ""

	totalbuild

fi
