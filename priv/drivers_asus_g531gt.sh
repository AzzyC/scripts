#!/bin/bash
driversSupportPage=(
	# Networking
	'Realtek LAN Driver' 'Intel Wireless LAN Driver' 'Wireless radio control driver' 'Intel Proset/Wireless Software V20.110.0.2602'\

	# Chipset
	'Intel® Dynamic Platform and Thermal Framework Driver' 'Intel Management Engine Components' 'Intel(R) Chipset Device Software' 'Intel(R) Serial IO Driver'\

	# Audio, Graphics, Pointing Device and Power Delivery
	'Realtek Audio Driver' 'Intel Graphics Driver' 'NVIDIA Graphic Driver' 'ASUS Precision TouchPad Driver' 'ASUS Precision TouchPad Driver (NumberPad)' 'ITE Power Delivery Driver'\

	# Software & Utility
	'ASUS System Control Interface V2' 'Nahimic Component Driver' 'Refreshrate Service'\
)

curl -Ls "https://rog.asus.com/support/webapi/product/GetPDDrivers?website=global&model=G531GV&pdid=10923&mode=&cpu=G531GT&osid=45&active=&LevelTagId=9180" | grep -E -- 'Title|FileSize|ReleaseD|Global|China' | sed 's/China.*//g; s/"//g; s/   *//g; s/,//g; s/Title/Driver Name/g; s/ReleaseDate/Released/g; s/Global/URL/g' > ./drivers.txt
sed -i "1i Script Bashed Date: $(date +'%a %b %d %Y')\n" ./drivers.txt

for drivers in "${driversSupportPage[@]}"; do
	printf '%s\n' ""
	grep -m1 "$drivers" -A3 ./drivers.txt
	curl -LO --progress-bar "$(grep -m1 "$drivers" -A3 ./drivers.txt | sed '/^Driver/d; /^File/d; /^Released/d; s/URL: //g')"
done
