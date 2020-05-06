#!/bin/bash

vendor=ALEXNDR/images/vendor.img
month=$(date +%m)

modvendor () {
	echo
	mkdir Vendor-NoForceEncyrpt
	mkdir DevBaseCollection
	unzip -j "$version" "$vendor" -d "$device" > /dev/null
	mv "$version" DevBaseCollection
	cd "$device"/ || return 1
	mkdir vendor
	sudo mount -o loop vendor.img vendor
	echo "Modifying $device Vendor.."
	cd vendor
	sudo sed -i '/ogg$/d' build.prop
	sudo sed -i '/steps=5$/d' build.prop
	sudo sed -i "s/patch=/patch=2020-${month}-05/" build.prop
	cd etc/
	sudo sed -i 's/forceencrypt/encryptable/' fstab.samsungexynos9810
	cd init/
	sudo mv pa_daemon_kinibi.rc pa_daemon_kinibi.rc.bak
	sudo mv secure_storage_daemon_kinibi.rc secure_storage_daemon_kinibi.rc.bak
	sudo mv vk_kinibi.rc vk_kinibi.rc.bak
	cd ../../lib
	sudo mv liboemcrypto.so liboemcrypto.so.bak
	cd ../..
	sudo umount vendor
	sudo rm -rf vendor
	mv vendor.img "${device}_${version:9:4}_Vendor.img"
	md5sum "${device}_${version:9:4}_Vendor.img" > "${device}_${version:9:4}_Vendor.img.md5sum"
	cd ..
	mv "$device" Vendor-NoForceEncyrpt
	echo "Vendor generated for $device"
}

getromfunc () {
	unset getrom

	echo
	echo "• Exit script: Hold 'Control + c'"
	echo
	echo "• Upload to Google Drive: Input 'up'"
	echo
	read -p "Otherwise, generate Vendor(s) by copy & pasting direct link addresses of DevBase AFH mirrors, using a space to separate. Links: " getrom
	
	if [[ "$getrom" =~ "up" ]]; then
		echo "Uploading to Google Drive.."
		if [ ! -d .gdrive ]; then
			echo "Not setup GoogleDrive AuthToken"
			return 1
		fi

		wget https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
		chmod +x gdrive-linux-x64
		sudo install gdrive-linux-x64 /usr/local/bin/gdrive
		gdrive upload -p 1qp133uQXFNur6tKqbs251uJ5CLCUxBgI -r Vendor-NoForceEncyrpt
		return 1

	fi

	getrom=( $getrom )

	echo

	if [[ "${#getrom[@]}" -eq "1" ]]; then
		wget "${getrom[0]}"
	fi
	if [[ "${#getrom[@]}" -eq "2" ]]; then
		wget "${getrom[0]}"
		echo
		wget "${getrom[1]}"
	fi
	if [[ "${#getrom[@]}" -eq "3" ]]; then
		wget "${getrom[0]}"
		echo
		wget "${getrom[1]}"
		echo
		wget "${getrom[2]}"
	fi

	searchfunc
}

searchfunc () {

	if [ -e G960*.zip ]; then
		device=G960
		version=$(echo G960*)
		modvendor
	fi

	if [ -e G965*.zip ]; then
		device=G965
		version=$(echo G965*)
		modvendor
	fi

	if [ -e N960*.zip ]; then
		device=N960
		version=$(echo N960*)
		modvendor
	fi

	getromfunc # If no zips found, will make user get one

}

clear # Clear the screen, immerse the script
echo "   ----------------"
echo "   |   ModVendor  |"
echo "   ----------------"
searchfunc # Check if there are zips to modify
