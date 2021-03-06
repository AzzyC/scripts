#!/bin/bash
driversSupportPage=(
	# Networking
	'Realtek LAN Driver' 'Intel Wireless LAN Driver' 'Wireless radio control driver' 'Intel Proset/Wireless Software V20.110.0.2602'\

	# Chipset
	'Intel® Dynamic Platform and Thermal Framework Driver' 'Intel Management Engine Components' 'Intel(R) Chipset Device Software' 'Intel(R) Serial IO Driver'\

	# Audio, Graphics, Pointing Device and Power Delivery
	'Realtek Audio Driver' 'Intel Graphics Driver' 'NVIDIA Graphic Driver' 'ASUS Precision TouchPad Driver' 'ASUS Precision TouchPad Driver (NumberPad)' 'ITE Power Delivery Driver'\

	# Software & Utility
	'ASUS System Control Interface V2' 'Nahimic Component Driver' 'Refreshrate Service' 'Asus Multi Antenna Service'\
	)

UniWinPkgs=(
	'NVIDIA Control Panel' 'Realtek Codec Console(Realtek Audio Driver Hardware Support App)' 'Sonic Studio 3 UWP'\
	)

zipFolders=(
	'WirelessProset' 'NahimicComponent' 'RefreshRate' 'AsusMultiAntenna'
	)

currentDir="$PWD"

download () {
	curl -Ls "https://rog.asus.com/support/webapi/product/GetPDDrivers?website=global&model=G531GV&pdid=10923&mode=&cpu=G531GT&osid=45&active=&LevelTagId=9180"\
	| grep -E -- 'Version|Title|FileSize|ReleaseD|Global|China'\
	| sed 's/China.*//g; s/"//g; s/   *//g; s/,//g; s/Title/Driver Name/g; s/ReleaseDate/Released/g; s/Global/URL/g' > ./drivers.txt
	sed -i "1i Script Bashed Date: $(date +'%a %b %d %Y')\n" ./drivers.txt

	for drivers in "${driversSupportPage[@]}"; do
		printf '%s\n' ""
		grep -m1 "$drivers" -B1 -A3 ./drivers.txt
		curl -LO --progress-bar "$(grep -m1 "$drivers" -A3 ./drivers.txt | sed '/^Driver/d; /^File/d; /^Released/d; s/URL: //g')"
	done

	curl -LO --progress-bar "$(curl -s "https://www.intel.co.uk/content/www/uk/en/support/detect.html"\
	| grep -m1 'Download now'\
	| sed 's/<a href=//; s/ class.*//; s/'\''//g; s/  *//')"

	sha256sum ./* > ./sha256sumDrivers.txt
}

install () {
	if net session &> /dev/null; then
		printf '%s\n' "" "Administrative Privileges: Active" ""
	else
		printf '%s\n' "" "User Privileges Only" "" "Please right-click on 'git-bash' application and 'Run as administrator'" "" "Exiting.."
		exit 0
	fi

	mkdir -p /c/DRIVERS/ && cd /c/DRIVERS/ || exit
	cp "$currentDir"/* /c/DRIVERS/
	sha256sum --check ./sha256sumDrivers.txt

	for zips in "${zipFolders[@]}"; do
		zipName="$(ls "${zips}"*.zip)"
		folderName="$(printf "$zipName" | sed 's/.zip//')"
		unzip -q "$zipName" -d "$folderName" && rm "$zipName"
	done

	read -r -a installer <<< "$(find "$PWD" -iname 'install*.bat' | tr -d '\n' | sed 's/bat/bat /g')"
	for install in "${installer[@]}"; do
		printf '%s\n' "" "Installing: $(printf "$install" | sed 's/.*DRIVERS\///; s/\/.*bat//')"
		"$install" &>/dev/null
		printf '%s\n' "Done" ""
	done

	for exe in "$PWD"/*.exe; do
		printf '%s\n' "Installing: $(printf "$exe" | sed 's/.*DRIVERS\///; s/.exe//')"
		"$exe"
		printf '%s\n' "Done" ""
	done

	cd "$currentDir" || exit
}

[[ "$*" =~ "download" ]] && download
[[ "$*" =~ "install" ]] && install
