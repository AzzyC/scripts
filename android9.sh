#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y openjdk-8-jdk python-lunch
git config --global user.name AzzyC
git config --global user.email azmath2000@gmail.com
git config --global color.ui true
if [ -d /usr/lib/jvm/java-8-openjdk-amd64/bin/ ];then
export PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin/:$PATH
fi
cd
git clone https://github.com/akhilnarang/scripts.git build_env --depth=1
cd build_env/
sudo chmod +x setup/android_build_env.sh
. setup/android_build_env.sh
cd
mkdir rom/ && cd rom/
repo init -u git://github.com/LineageOS/android.git -b lineage-16.0 --no-clone-bundle --depth=1
cd .repo/
git clone https://github.com/AzzyC/local_manifests.git -b android-9.0 --depth=1
cd ..
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --quiet
git apply device/samsung/universal9810-common/patches/0001-Get-SignalStrength-From-RIL-prop.patch
git apply device/samsung/universal9810-common/patches/0002-Calculate-gsmdBm-from-RSSI.patch
git apply device/samsung/universal9810-common/patches/0003-colorspace-hwc-fix.patch
. build/envsetup.sh
lunch lineage_starlte-userdebug
make bacon -j$(nproc --all) 2>&1 | tee ../make_starlte_android9.txt
lunch lineage_star2lte-userdebug
make bacon -j$(nproc --all) 2>&1 | tee ../make_star2lte_android9.txt
cd ..
mkdir compiled/
sleep 5
if [ -d ~/rom/out/target/product/starlte ] && [ -d ~/rom/out/target/product/star2lte ]
	then
		mv ~/rom/out/target/product/star*/lineage-1*.zip ~/compiled/
		mv ~/rom/out/target/product/star*/lineage-1*.zip.md5sum ~/compiled/
fi
