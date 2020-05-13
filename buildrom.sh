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

if [[ "$1" != "quiet" ]]; then

	if [[ "$1" =~ ^(lineage10|crdroid10)$ ]]
	then
		"$1" # Use the variable to call for the function, rather than specifying each time
	fi

	if [[ "$2" =~ ^(starlte|star2lte|crownlte)$ ]]; then

		if [[ "$@" =~ "starlte" ]]; then
			devices+=('starlte')
		fi

		if [[ "$@" =~ "star2lte" ]]; then
			devices+=('star2lte')
		fi

		if [[ "$@" =~ "crownlte" ]]; then
			devices+=('crownlte')
		fi

		if [[ ! "$@" =~ "starlte" ]] && [[ ! "$@" =~ "star2lte" ]] && [[ ! "$@" =~ "crownlte" ]]; then
			printf '%s\n' "" "Typo made initially stating a devices name. Try again:" "Which device(s) do you want to build the $romname for? (starlte/star2lte/crownlte)"
			printf "Device(s): "
			read -r -a devices
		fi
	fi

	if [[ ! -z "$romname" ]] && [[ ! -z "$devices" ]]; then

		while [[ ! "$changesetup" =~ ^(Y|y|N|n)$ ]]
		do
			printf '%s\n' "" "Selected ROM: $romname" "" "Selected Device(s):" "${devices[@]}"
			printf "Do you want to change? (y/N): "
			read -n 2 -r changesetup
			printf '%s\n' ""
		done

		if [[ "$changesetup" =~ ^[Yy]$ ]]; then
			unset romname
			unset devices
		fi
		unset changesetup
	fi

	if [[ ! -n "$romname" ]]; then
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

	while [[ ! "${devices[@]}" =~ "starlte" ]] && [[ ! "${devices[@]}" =~ "star2lte" ]] && [[ ! "${devices[@]}" =~ "crownlte" ]]
	do
		printf '%s\n' "" "Which device(s) do you want to build the $romname for? (starlte/star2lte/crownlte)"
		printf "Device(s): "
		read -r -a devices
	done

	printf '%s\n' "" "Finalised Setup: $romname for" "${devices[@]}" ""

	totalbuild

fi

# This function of statements will reconfigure the time difference before and after desired commands, to make sure that the time displayed is correct
timecheck () {
	starthour="${start[0]}"
	startminute="${start[1]}"
	startsecond="${start[2]}"

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

	statetime="$(printf '%02dh:%02dm:%02ds' $((endhour-starthour)) $((endminute-startminute)) $((endsecond-startsecond)))"
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
	git clone https://github.com/akhilnarang/scripts.git build_env --depth=1 # `--depth=1` No time wasting fetching commit history
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

	if [[ -d "$romname" ]]; then
	cd "$romname"
	rm -rf .repo
	repo init -u "$rommanifest" --depth=1 --no-clone-bundle --no-tags -q
	cd .repo || return
	git clone https://github.com/synt4x93/local_manifests.git -b lineage-17.1 --depth=1 -q

	printf '%s\n' "" "$romname manifest repo initialised at $(date +%T)" ""
	telegram "$romname manifest repo initialised"

	fi

}

romsync () {
	cd ~/"$romname" || return

	if [[ -d .repo ]]; then

		start=( "$(date +'%-H %-M %-S')" )
		repo sync -c --force-sync -j$(nproc --all) --no-clone-bundle --no-tags --prune --q
		end=( "$(date +'%-H %-M %-S')" )

		timecheck # Use `timecheck` function to make sure the time is correctly formatted

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

	if [[ "${devices[@]}" =~ "starlte" ]]; then
		lunch "$lunchname"_starlte-userdebug

		start=( "$(date +'%-H %-M %-S')" )
		make bacon -j$(nproc --all) 2>&1 | tee ~/make_starlte.txt
		end=( "$(date +'%-H %-M %-S')" )

		awk '/FAILED:/,EOF' ~/make_starlte.txt ~/fail_starlte.txt

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

		start=( "$(date +'%-H %-M %-S')" )
		make bacon -j$(nproc --all) 2>&1 | tee ~/make_star2lte.txt
		end=( "$(date +'%-H %-M %-S')" )

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

		start=( "$(date +'%-H %-M %-S')" )
		make bacon -j$(nproc --all) 2>&1 | tee ~/make_crownlte.txt
		end=( "$(date +'%-H %-M %-S')" )

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

totalbuild () {
	buildenv
	init
	romsync
	configtree
	build
}
