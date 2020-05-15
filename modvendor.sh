#!/bin/bash

modvendor () {
	printf '%s\n' "" "Found device zip: $device"

	printf '%s\n' "" "Extracting Vendor from zip.."
	unzip -j "$version" "ALEXNDR/images/vendor.img" -d "$device" > /dev/null
	mv "$version" DevBaseCollection

	if [[ -d "$device" ]]; then
		cd "$device"
	else
		printf "Running low on disk space?"
		return 2>/dev/null || exit
	fi

	mkdir vendor
	sudo mount -o loop vendor.img vendor
	cd vendor

	printf '%s\n' "" "Now modifying $device Vendor.."
	sudo sed -i '/ogg$/d' build.prop
	sudo sed -i '/steps=5$/d' build.prop
	sudo sed -i "s/patch=/patch=2020-$(date +%m)-05/" build.prop
	cd etc/
	sudo sed -i 's/forceencrypt/encryptable/' fstab.samsungexynos9810
	cd init/
	sudo mv icd_over_five_vendor.rc icd_over_five_vendor.rc.bak
	sudo mv pa_daemon_kinibi.rc pa_daemon_kinibi.rc.bak
	sudo mv secure_storage_daemon_kinibi.rc secure_storage_daemon_kinibi.rc.bak
	sudo mv vendor.samsung.hardware.tlc.atn@1.0-service.rc vendor.samsung.hardware.tlc.atn@1.0-service.rc.bak
	sudo mv vendor.samsung.hardware.tlc.iccc@1.0-service.rc vendor.samsung.hardware.tlc.iccc@1.0-service.rc.bak
	sudo mv vendor.samsung.hardware.tlc.tima@1.0-service.rc vendor.samsung.hardware.tlc.tima@1.0-service.rc.bak
	sudo mv vendor.samsung.hardware.tlc.ucm@1.0-service.rc vendor.samsung.hardware.tlc.ucm@1.0-service.rc.bak
	sudo mv vendor.samsung_slsi.hardware.ExynosHWCServiceTW@1.0-service.rc vendor.samsung_slsi.hardware.ExynosHWCServiceTW@1.0-service.rc.bak
	sudo mv vk_kinibi.rc vk_kinibi.rc.bak
	cd ../../lib
	sudo mv liboemcrypto.so liboemcrypto.so.bak
	cd ../..

	sudo umount vendor
	sudo rm -rf vendor
	mv vendor.img "${device}_${version:9:4}_Vendor.img"
	md5sum "${device}_${version:9:4}_Vendor.img" > "${device}_${version:9:4}_Vendor.img.md5sum"
	cd ~
	mv "$device" Vendor-NoForceEncyrpt
	printf '%s\n' "" "Vendor generated for $device"
}

getromfunc () {
	unset getrom
	unset device
	unset version

	printf '%s\n' "" "• Exit script: Hold 'Control + c'" ""
	printf '%s\n' "" "• Copy & paste direct link URL's of DevBase AFH mirrors, using a space to separate, to begin generating Vendor(s)" ""
	printf '%s\n' "" "• Upload to Google Drive: Input 'up'"
	printf "URL(s) or 'up': "
	read -r -a getrom

	if [[ "${getrom[@]}" =~ "up" ]]; then

		if [ ! -d .gdrive ]; then
			printf '%s\n' "" "Not setup GoogleDrive AuthToken" ""
			return 2>/dev/null || exit
		else
			printf '%s\n' "" "Uploading to Google Drive.." ""
			sudo wget -q -nc -O /usr/local/bin/gdrive https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
			sudo chmod a+x /usr/local/bin/gdrive
			gdrive upload -p 1qp133uQXFNur6tKqbs251uJ5CLCUxBgI -r Vendor-NoForceEncyrpt
			return 2>/dev/null || exit
		fi


	fi

	printf "\n"

	if [[ "${#getrom[@]}" -eq "1" ]]; then
		wget "${getrom[0]}"
	fi
	if [[ "${#getrom[@]}" -eq "2" ]]; then
		wget "${getrom[0]}"
		printf "\n"
		wget "${getrom[1]}"
	fi
	if [[ "${#getrom[@]}" -eq "3" ]]; then
		wget "${getrom[0]}"
		printf "\n"
		wget "${getrom[1]}"
		printf "\n"
		wget "${getrom[2]}"
	fi

	searchfunc
}

searchfunc () {

	printf '%s\n' "" "Checking if there are any ROM zips already downloaded.."

	if [[ ! -z "$(ls -U G960*.zip 2>/dev/null)" ]]; then
		device=G960
		version="$(ls -U G960*)"
		modvendor
	fi

	if [[ ! -z "$(ls -U G965*.zip 2>/dev/null)" ]]; then
		device=G965
		version="$(ls -U G965*)"
		modvendor
	fi

	if [[ ! -z "$(ls -U N960*.zip 2>/dev/null)" ]]; then
		device=N960
		version="$(ls -U N960*)"
		modvendor
	fi

	getromfunc # If no zips found, will make user get one

}

clear # Clear the screen, immerse the script
printf '%s\n' "\-\- ---------------- \-\-"
printf '%s\n' "\-\- |   ModVendor  | \-\-"
printf '%s\n' "\-\- ---------------- \-\-"

if [[ ! -x "${BASH_SOURCE[0]}" ]]; then
	printf '%s\n' "Script is not executable!"
	printf '%s\n' "Copy & Paste: sudo chmod +x modvendor.sh"
	return 2>/dev/null || exit
fi

cd ~
if [[ ! -d Vendor-NoForceEncyrpt ]]; then
	mkdir Vendor-NoForceEncyrpt
fi
if [[ ! -d DevBaseCollection ]]; then
	mkdir DevBaseCollection
fi

searchfunc # Check if there are zips to modify
