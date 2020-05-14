#!/bin/bash

vendor="ALEXNDR/images/vendor.img"
month="$(date +%m)"

modvendor () {
	unzip -j "$version" "$vendor" -d "$device" > /dev/null
	mv "$version" DevBaseCollection
	cd "$device"/ || printf "Running low on disk space?" && return
	mkdir vendor
	sudo mount -o loop vendor.img vendor
	cd vendor || printf '%s\n' "Script does not have executable permission" "" "Copy & Paste: sudo chmod +x modvendor.sh" && return
	printf '%s\n' "" "Modifying $device Vendor.." ""
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
	cd ~
	mv "$device" Vendor-NoForceEncyrpt
	printf '%s\n' "" "Vendor generated for $device" ""
}

getromfunc () {
	unset getrom

	printf '%s\n' "" "• Exit script: Hold 'Control + c'" ""
	printf '%s\n' "" "• Upload to Google Drive: Input 'up'" ""
	printf '%s\n' "" "Otherwise copy & paste direct link address(es) of DevBase AFH mirrors, using a space to separate, to begin generating Vendor(s)"
	printf "Links: "
	read -r -a getrom

	if [[ "${getrom[@]}" =~ "up" ]]; then

		if [ ! -d .gdrive ]; then
			printf '%s\n' "" "Not setup GoogleDrive AuthToken" ""
			return
		else
			printf '%s\n' "" "Uploading to Google Drive.." ""
			sudo wget -q -nc -O /usr/local/bin/gdrive https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
			sudo chmod a+x /usr/local/bin/gdrive
			gdrive upload -p 1qp133uQXFNur6tKqbs251uJ5CLCUxBgI -r Vendor-NoForceEncyrpt
			return
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

	if [[ ! -z "$(ls G960*.zip 2>/dev/null)" ]]; then
		device=G960
		version="$(ls G960*)"
		modvendor
	fi

	if [[ ! -z "$(ls G965*.zip 2>/dev/null)" ]]; then
		device=G965
		version="$(ls G965*)"
		modvendor
	fi

	if [[ ! -z "$(ls N960*.zip 2>/dev/null)" ]]; then
		device=N960
		version="$(ls N960*)"
		modvendor
	fi

	getromfunc # If no zips found, will make user get one

}

clear # Clear the screen, immerse the script
printf "\-\- ---------------- \-\-\n"
printf "\-\- |   ModVendor  | \-\-\n"
printf "\-\- ---------------- \-\-\n"

cd ~
if [[ ! -d Vendor-NoForceEncyrpt ]]; then
	mkdir Vendor-NoForceEncyrpt
fi
if [[ ! -d DevBaseCollection ]]; then
	mkdir DevBaseCollection
fi

searchfunc # Check if there are zips to modify
