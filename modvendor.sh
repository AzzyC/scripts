#!/bin/bash

vendor=ALEXNDR/images/vendor.img
month=$(date +%m)

modvendor () {
	echo
	echo "Modifying $device.."
	mkdir Vendor-NoForceEncyrpt
	mkdir DevBaseCollection
	unzip -j "$version" "$vendor" -d "$device" > /dev/null
	mv "$version" DevBaseCollection
	cd "$device"/
	mkdir vendor
	sudo mount -o loop vendor.img vendor
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
	read -p "Otherwise, generate Vendor(s) by copy & pasting direct link addresses of DevBase AFH mirrors, using a comma or space to separate: " getrom
	
	getrom=$(echo "$getrom" | sed 's/,//g')
	getrom=( $getrom )

	echo
	wget "${getrom[0]}"
	wget "${getrom[1]}"
	wget "${getrom[2]}"
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
searchfunc # Check if there are zips to modify
