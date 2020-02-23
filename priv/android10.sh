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
repo init -u git://github.com/LineageOS/android.git -b lineage-17.1 --no-clone-bundle --depth=1
cd .repo/
git clone https://github.com/AzzyC/local_manifests.git -b android-10.0 --depth=1
cd ..
telegram -MD "Syncing [LineageOS 17.1](https://github.com/LineageOS/android)"
syncstart=`date +%s`
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --quiet
syncend=`date +%s`
synctimeM=$(((syncend-syncstart)/60))
synctimeS=$((syncend-syncstart))
telegram -M "Sync completed in "$synctimeM" minutes or "$synctimeS" seconds, for [LineageOS 17.1](https://github.com/LineageOS/android)"
. build/envsetup.sh
lunch lineage_starlte-userdebug
telegram -MD "Build started for Starlte, [LineageOS 17.1](https://github.com/LineageOS/android)"
makestarstart=`date +%s`
make bacon -j$(nproc --all) 2>&1 | tee ../make_starlte_android10.txt
makestarend=`date +%s`
makestartimeM=$(((makestarend-makestarstart)/60))
makestartimeS=$((makestarend-makestarstart))
grep -iE --color=always 'crash|error|fail|fatal' ../make_starlte_android10.txt 2>&1 | tee ../trim_errors_starlte_android10.txt
if compgen -G "$rom_out/starlte/lineage-1*.zip" > /dev/null; then
telegram -f ../trim_errors_starlte_android10.txt "Build completed in "$makestartimeM" minutes or "$makestartimeS" seconds.
Trimmed errors from make_starlte_android10 (if any)"
lunch lineage_star2lte-userdebug
telegram -MD "Build started for Star2lte, [LineageOS 17](https://github.com/LineageOS/android)"
makestar2start=`date +%s`
make bacon -j$(nproc --all) 2>&1 | tee ../make_star2lte_android10.txt
makestar2end=`date +%s`
makestar2timeM=$(((makestar2end-makestar2start)/60))
makestar2timeS=$((makestar2end-makestar2start))
grep -iE --color=always 'crash|error|fail|fatal' ../make_star2lte_android10.txt 2>&1 | tee ../trim_errors_star2lte_android10.txt
telegram -f ../trim_errors_star2lte_android10.txt "Build completed in "$makestar2timeM" minutes or "$makestar2timeS" seconds.
Trimmed errors from make_star2lte_android10 (if any)"
cd ..
date=`date +%d-%m-%y`
mkdir $date/
sleep 2
if compgen -G "$rom_out/star2lte/lineage-1*.zip" > /dev/null; then
	mv $rom_out/star*/lineage-1*.zip ~/$date/
	mv $rom_out/star*/lineage-1*.zip.md5sum ~/$date/
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
	telegram -f ../trim_errors_starlte_android10.txt "Build has failed after "$makestartimeM" minutes or "makestartimeS" seconds;
	Script aborted"
	sleep 1200
	. ~/scripts/delinstance.sh
fi
