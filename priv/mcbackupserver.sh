#!/bin/bash

mcfolderid=1s43Sn6h_aoWQ_T2-GpfKs8t7Dy0rMU0n
date=`date -d '+1 hour' '+%d-%m-%y_%H:%M'`
javarun='java -Xms2G -Xmx5G -jar forge-1.15.2-31.1.0.jar nogui'
scriptstart=`date +%s`

cd

if [[ -e backup && -e restore ]]; then
echo "Both 'backup' and 'restore' file exist"
echo "Delete one and re-bash the script"
return 1
fi

sudo apt update -y > /dev/null
sudo apt install unzip zip openjdk-8-jdk-headless -y > /dev/null

if [ ! -e gdrive-linux-x64 ]; then
echo "Installing GoogleDrive"
wget -q https://github.com/gdrive-org/gdrive/releases/download/2.1.0/gdrive-linux-x64
chmod +x gdrive-linux-x64
sudo install gdrive-linux-x64 /usr/local/bin/gdrive
fi

if [ -e backup ]; then
echo "'backup' file detected"
if [ ! -d .gdrive ]; then
echo "Not setup GoogleDrive AuthToken"
return 1
fi
rm backup
echo "Beginning server backup.."
mkdir minecraft
zip -r minecraft_server.zip minecraft_server/
sha256sum minecraft_server.zip > minecraft_server.zip.sha256sum
touch $date
mv minecraft_server.zip* minecraft
mv $date minecraft
gdrive upload -p $mcfolderid -r minecraft
rm -rf minecraft
scriptend=`date +%s`
echo "Server backed up to GoogleDrive in $((scriptend-scriptstart)) second(s)" 2>&1 | tee -a ~/timeelapsed.txt
fi

if [ -e restore ]; then
echo "'restore' file detected"
if [ ! -d .gdrive ]; then
echo "Not setup GoogleDrive AuthToken"
return 1
fi
rm restore
echo "Beginning server restore.."
gdrive download -r $mcfolderid
mv minecraft/minecraft/minecraft_server.zip* ~
checksum=`head -c 64 minecraft_server.zip.sha256sum`
echo "Checking sha256sum of minecraft_server.zip .."
if ! echo "$checksum minecraft_server.zip" | sha256sum -c --quiet "minecraft_server.zip.sha256sum"; then
echo ""
echo "Checksum failed"
return 1
else
echo "File integrity valid"
fi
unzip minecraft_server.zip
if [ ! -z "$(ls minecraft/mods)" ]; then
mv minecraft/mods/* minecraft_server/mods
else
echo "No new mods found to import to server"
fi
rm minecraft_server.zip*
rm -rf minecraft
cd minecraft_server
scriptend=`date +%s`
echo "Server restored from GoogleDrive in $((scriptend-scriptstart)) second(s)" 2>&1 | tee -a ~/timeelapsed.txt
echo "Now running server.."
$javarun
fi
