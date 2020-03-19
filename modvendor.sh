#!/bin/bash

vendor=ALEXNDR/images/vendor.img

if [ -e G960*.zip ]; then
device=G960
version=$(echo G960*)
fi

if [ -e G965*.zip ]; then
device=G965
version=$(echo G965*)
fi

if [ -e N960*.zip ]; then
device=N960
version=$(echo N960*)
fi

unzip -j "$version" "$vendor" -d "$device"
cd $device/
mkdir vendor
sudo mount -o loop vendor.img vendor
cd vendor
sudo sed -i '/ogg$/d' build.prop
sudo sed -i '/steps=5$/d' build.prop
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
mv vendor.img ${device}_${version:9:4}_Vendor.img
md5sum ${device}_${version:9:4}_Vendor.img > ${device}_${version:9:4}_Vendor.img.md5sum
