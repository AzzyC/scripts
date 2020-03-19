#!/bin/bash

vendor=ALEXNDR/images/vendor.img

function modvendor {
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
}

if [[ -f "G960*.zip" ]]; then
unzip -j "G960*.zip" "$vendor" -d "G960"
cd G960/
modvendor
mv vendor.img G960_Vendor.img
fi

if [[ -f "G965*.zip" ]]; then
unzip -j "G965*.zip" "$vendor" -d "G965"
cd G965/
modvendor
mv vendor.img G965_Vendor.img
fi

if [[ -f "N960*.zip" ]]; then
unzip -j "N960*.zip" "$vendor" -d "N960"
cd N960/
modvendor
mv vendor.img N960_Vendor.img
fi
