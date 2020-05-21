#!/bin/bash
rom_out=~/rom/out/target/product
cd
sudo apt update && sudo apt upgrade -y
sudo apt install -y openjdk-8-jdk python-lunch lsb-core
git config --global user.name AzzyC
git config --global user.email azmath2000@gmail.com
git config --global color.ui true
if [ -d /usr/lib/jvm/java-8-openjdk-amd64/bin/ ]; then
export PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin/:$PATH
fi
git clone https://github.com/akhilnarang/scripts.git build_env --depth=1
sudo chmod +x build_env/setup/android_build_env.sh
. build_env/setup/android_build_env.sh
sudo curl --create-dirs -L -o /usr/local/bin/telegram -O -L https://raw.githubusercontent.com/bluedogerino/jenkins_rom/master/telegram
sudo chmod a+x /usr/local/bin/telegram
sudo chmod +x .telegram.sh
mkdir rom/ && cd rom/
repo init -u https://github.com/Evolution-X/manifest -b ten --no-clone-bundle --depth=1
cd .repo/
git clone https://github.com/AzzyC/local_manifests.git -b android-10.0 --depth=1
cd ..
telegram -MD "Syncing [EvolutionX 4.1](https://github.com/Evolution-X/manifest/tree/ten)"
syncstart=`date +%s`
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --quiet
syncend=`date +%s`
synctimeM=$(((syncend-syncstart)/60))
synctimeS=$((syncend-syncstart))
telegram -MD "Sync completed in "$synctimeM" minutes or "$synctimeS" seconds, for [EvolutionX 4.1](https://github.com/Evolution-X/manifest/tree/ten)"
cd device/samsung/universal9810-common/
sed -i '/^SamsungD/d' universal9810-common.mk
cd ../starlte/
sed -i 's/lineage/aosp/g' AndroidProducts.mk
mv lineage_starlte.mk aosp_starlte.mk
sed -i 's/lineage/aosp/g' aosp_starlte.mk
cd ../star2lte/
sed -i 's/lineage/aosp/g' AndroidProducts.mk
mv lineage_star2lte.mk aosp_star2lte.mk
sed -i 's/lineage/aosp/g' aosp_star2lte.mk
cd ~/rom/hardware/samsung/
sed -i '46d' Android.mk
sed -i '22,24d' AdvancedDisplay/Android.mk
rm -rf hidl/power
cd ~/rom/
. build/envsetup.sh
export CUSTOM_BUILD_TYPE=OFFICIAL
export TARGET_BOOT_ANIMATION_RES=1080
export TARGET_GAPPS_ARCH=arm64
export TARGET_SUPPORTS_GOOGLE_RECORDER=true
lunch aosp_starlte-userdebug
telegram -MD "Build started for Starlte, [EvolutionX 4.1](https://github.com/Evolution-X/manifest/tree/ten)"
makestarstart=`date +%s`
mka bacon -j$(nproc --all) 2>&1 | tee ../make_starlte_android10.txt
makestarend=`date +%s`
makestartimeM=$(((makestarend-makestarstart)/60))
makestartimeS=$((makestarend-makestarstart))
grep -iE 'crash|error|fail|fatal|unknown' ../make_starlte_android10.txt 2>&1 | tee ../trim_errors_starlte_android10.txt
if compgen -G "$rom_out/starlte/EvolutionX_4.*.zip" > /dev/null; then
telegram -f ../trim_errors_starlte_android10.txt "Build completed in "$makestartimeM" minutes or "$makestartimeS" seconds.
Trimmed errors from make_starlte_android10 (if any)"
lunch aosp_star2lte-userdebug
telegram -MD "Build started for Star2lte, [EvolutionX 4.1](https://github.com/Evolution-X/manifest/tree/ten)"
makestar2start=`date +%s`
mka bacon -j$(nproc --all) 2>&1 | tee ../make_star2lte_android10.txt
makestar2end=`date +%s`
makestar2timeM=$(((makestar2end-makestar2start)/60))
makestar2timeS=$((makestar2end-makestar2start))
grep -iE 'crash|error|fail|fatal|unknown' ../make_star2lte_android10.txt 2>&1 | tee ../trim_errors_star2lte_android10.txt
telegram -f ../trim_errors_star2lte_android10.txt "Build completed in "$makestar2timeM" minutes or "$makestar2timeS" seconds.
Trimmed errors from make_star2lte_android10 (if any)"
cd ..
date=`date +%d-%m-%y`
mkdir $date/
sleep 2
if compgen -G "$rom_out/star2lte/EvolutionX_4.*.zip" > /dev/null; then
	mv $rom_out/star*/EvolutionX_4.*.zip ~/$date/
	mv $rom_out/star*/EvolutionX_4.*.zip.md5sum ~/$date/
fi
wget https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
chmod +x gdrive-linux-x64
sudo install gdrive-linux-x64 /usr/local/bin/gdrive
gdrive upload -p 1qp133uQXFNur6tKqbs251uJ5CLCUxBgI -r $date
telegram -MD "Uploads completed,
[View Drive](https://drive.google.com/open?id=1qp133uQXFNur6tKqbs251uJ5CLCUxBgI)"
sleep 2
. ~/scripts/delinstance.sh
else
	telegram -f ../trim_errors_starlte_android10.txt "Build has failed after "$makestartimeM" minutes or "$makestartimeS" seconds;
	Script aborted"
	telegram -f ../make_starlte_android10.txt "Have the full log, just in case, amigo!"
	sleep 1200
	. ~/scripts/delinstance.sh
fi
