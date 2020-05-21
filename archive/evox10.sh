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
mkdir rom/ && cd rom/
repo init -u https://github.com/Evolution-X/manifest -b ten --no-clone-bundle --depth=1
cd .repo/
git clone https://github.com/AzzyC/local_manifests.git -b android-10.0 --depth=1
cd ..
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --quiet
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
cd ../crownlte/
sed -i 's/lineage/aosp/g' AndroidProducts.mk
mv lineage_crownlte.mk aosp_crownlte.mk
sed -i 's/lineage/aosp/g' aosp_crownlte.mk
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
mka bacon -j$(nproc --all) 2>&1 | tee ../make_starlte_android10.txt
grep -iE 'crash|error|fail|fatal|unknown' ../make_starlte_android10.txt 2>&1 | tee ../trim_errors_starlte_android10.txt
if compgen -G "$rom_out/starlte/EvolutionX_4.*.zip" > /dev/null; then
lunch aosp_star2lte-userdebug
mka bacon -j$(nproc --all) 2>&1 | tee ../make_star2lte_android10.txt
grep -iE 'crash|error|fail|fatal|unknown' ../make_star2lte_android10.txt 2>&1 | tee ../trim_errors_star2lte_android10.txt
lunch aosp_crownlte-userdebug
mka bacon -j$(nproc --all) 2>&1 | tee ../make_crownlte_android10.txt
grep -iE 'crash|error|fail|fatal|unknown' ../make_crownlte_android10.txt 2>&1 | tee ../trim_errors_crownlte_android10.txt
cd ..
sleep 2
mkdir compiled
if compgen -G "$rom_out/crownlte/EvolutionX_4.*.zip" > /dev/null; then
	mv $rom_out/*lte/EvolutionX_4.*.zip ~/compiled/
	mv $rom_out/*lte/EvolutionX_4.*.zip.md5sum ~/compiled/
fi
else
	cat trim_errors_starlte_android10.txt
	echo "An error ocurred and this is the preview. To see better details view 'make_starlte_android10.txt'"
fi
