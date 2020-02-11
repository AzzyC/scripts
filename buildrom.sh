#!/bin/bash
# Do note this script by default compiles LineageOS 15.1 for both starlte and star2lte. There are commands to build for crownlte
# and other ROM's but they have been disabled to focus on one function. 
# If you are happy with the default script, or are done editing, type in to your terminal:
# '$ sudo chmod +x scripts/buildrom.sh' - Make the script executable;
# '$ bash scripts/buildrom.sh' - Activate the script.
# Key: To enable a command, remove the '#' at the start of the line; to disbale a command, insert a '#'.
# Example commands have no space between the '#' and the start of the command, so enable as you please but also disable accordingly,
# to avoid command conflicts and potentially an unsuccessful script.
# I would reccomend to keep the entirity of the script, to ensure that the guided comments are still there for reference, 
# so only disbable the commands you no longer want/require.
# If you want to stop/interupt the script at any point, input 'Ctrl + C'. You will notice that the script skipped the current
# process and moved onto the next command, but in most cases the script should abort anyway, due to a lacking command(s).
# Be prepared to see errors though as the script comes to its end, because the later commands are based on the previous commands
# having been done.
# Lastly, this is open so don't hesitate to share your ideas too! Telling me how this script could be improved could also help
# future users, so please do let me know on Telegram, @inivisibazinga2, or do a 'Pull Request' (PR) on GitHub and I will 
# review and add your changes when I can!
touch .buildrombashed
sudo chmod +x ~/scripts/gcloudvnc.sh
# Give executable permission to other script(s).
if [ ! -e ".gcloudvncbashed" ]; then
# If user has bashed the './gcloudvnc.sh' script, prior to this one, then there is no need to spend time checking for
# updates (to then upgrade) as it was already done. A placeholder file was created in the './gcloudvnc.sh' script
# called 'updated' to check for this.
sudo apt update && sudo apt upgrade -y
fi
# Update Distro's repository to be able to fetch and install all needed packages in next command.
sudo apt install -y autoconf automake axel bc binutils-static bison build-essential clang cmake curl \
expat figlet flex g++ g++-multilib gawk gcc gcc-multilib git-core gnupg gperf imagemagick lib32ncurses5-dev \
lib32z1-dev libtinfo5 libc6-dev libcap-dev libesd0-dev libwxgtk2.8-dev libexpat1-dev libgmp-dev liblz4-* \
liblzma* libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils \
lunzip lzma* lzop maven ncftp ncurses-dev openjdk-8-jdk patch patchelf pkg-config pngcrush pngquant \
python python-all-dev re2c schedtool squashfs-tools subversion texinfo toilet unzip w3m xsltproc zip zlib1g-dev
# The abvove will install packages that are needed to compile most ROM's, for systems above Ubuntu 14.04.
# If you find that during your compile of a ROM that it errors to require another package then simply:
# '$ sudo apt install <saidPackageName>' and let me know so I can add it for future users.
# Once you have installed these building packages you can disable the command, as now you only need to update or upgrade.
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo
sudo chmod a+x /usr/local/bin/repo
# The above will install the repo tool which will allow you to download and then stay in sync with a ROM's Git source, if it is
# updated at remote.
# repo is a python wrapper for git.
git config --global user.name AzzyC
git config --global user.email azmath2000@gmail.com
# Change above config according to your GitHub account.
git config --global color.ui true
# Skips prompt on 'repo init' requiring User input for colourised tags during sync.
if [ ! -d "compiled" ]; then
# The script is checking 'if' the 'compiled' directory does not exist..
mkdir ~/compiled/
# 'then' to make one if there is not. This is where you can collect your ROM's in an organised manner.
fi
while ! [[ $REPLY =~ ^(C|c|R|r|D|d)$ ]] && [ -d "rom" ]
do
	echo ""
	echo "Size of existing 'rom' directory"
	du -h rom/
	echo ""
	echo "'c'/'C' = Continue"
	echo "'r'/'R' = Rename 'rom'"
	echo "'d'/'D' = Delete 'rom'; Start fresh"
	echo ""
	read -p "buildrom.sh: A 'rom' directory already exists. If syncing & compiling same ROM source that is in this directory, input \
'c' to continue. If are syncing a new ROM source and want to keep your previous, rename existing 'rom' directiory by \
inputting 'r' which will rename to 'prevROM'. If you want to save storage and start fresh removing existing 'rom' \
directory, input 'd' to delete. (c/r/d) " -n 2 -r
# This prompt is to avoid error or loss of a synced ROM source, so either make sure it's the same ROM source being synced or 
# seperate the sources into different folders.
# Note: ROM Sources take up a lot of space e.g. 160GB, so if you do choose to seperate them then make sure you have the storage
# as required.
if [[ $REPLY =~ ^[Rr]$ ]]
then
	echo ""
	mv rom/ prevROM/
	echo ""
	echo ""
	echo "'rom' directory renamed to 'prevROM'"
	echo ""
elif [[ $REPLY =~ ^[Dd]$ ]]
	then
		echo ""
		sudo rm -rf rom/
		echo "'rom' directory removed"
		echo ""
elif [[ ! $REPLY =~ ^[Cc|Rr|Dd]$ ]]
	then
		echo ""
		echo ""
		echo "You did not input 'c'/'C' ; 'r'/'R' ; 'd'/'D' ! Try again."
		echo ""
fi
done
if [ ! -d "rom" ]; then
# The script is checking 'if' the 'rom' directory does not exist..
mkdir ~/rom/
# 'then' to make one then to make one if there is not.
fi
cd ~/rom/
echo ""
PS3='Which Rom_AndroidVersion would you like to build? (1/2/3/4) '
options=("LineageOS 15.1 (Oreo)" "LineageOS 16 (Pie)" "PixelExperience (Pie)" "Other ROM")
select opt in "${options[@]}"
do
    case $opt in
        "LineageOS 15.1 (Oreo)")
            echo ""
            echo "You chose '$opt' at Option $REPLY"
            echo ""
            repo init -u https://github.com/LineageOS/android.git -b lineage-15.1
# This will initialise a manifest repo to sync LineageOS 15.1 (Oreo).
            echo ""
            break
            ;;
        "LineageOS 16 (Pie)")
            echo ""
            echo "You chose '$opt' at Option $REPLY"
            echo ""
            repo init -u git://github.com/LineageOS/android.git -b lineage-16.0
# This will initialise a manifest repo to sync LineageOS 16 (Pie).
            echo ""
            break
            ;;
        "PixelExperience (Pie)")
            echo ""
            echo "You chose '$opt' at Option $REPLY"
            echo ""
            repo init -u https://github.com/PixelExperience/manifest -b pie
# This will initialise a manifest repo to sync Pixel Experience (Pie).
            echo ""
            break
            ;;
        "Other ROM")
            echo ""
            echo "You chose '$opt' at Option $REPLY"
            echo ""
            echo "No predefined ROM Source manifest selected."
            echo "Assuming User has edited/added their chosen ROM Source, below this prompt."
# This Option is for the Users that have already edited this script and repo initialised a ROM of their choice.
# Users can add the command to init a ROM after this prompt, under 'done', whereby examples have been given.
# (Can enable)
            echo ""
            break
            ;;
        *) echo ""
            echo "Invalid: '$REPLY'. You did not choose '1' '2' '3' or '4'! Try again."
            echo ""
            ;;
    esac
done
#repo init -u git://github.com/AospExtended/manifest.git -b 8.1.x
#repo init -u https://github.com/Havoc-OS/android_manifest.git -b oreo
#repo init -u https://github.com/ResurrectionRemix/platform_manifest.git -b oreo
# Common task: Search on Google for '<romYouWantToBuildsName> manifest' e.g. 'bootleggers manifest', 'aex manifest'.
#
# The '-b' in the above example commands stands for 'branch' which in most cases you will have to specify as a different
# branch may be defaulted, within a particular repository. So become familiar with this and make sure you're not wasting
# time syncing an undesired source.
#
# A manifest is an .xml file which simply automates the cloning of all the all the ROM source directories, rather than a user
# manually having to clone hundreds of repositories leading to insanity. The manifest, can be found within a hidden directory
# where 'repo init' command occurred, called '.repo' => '~/rom/.repo/manifests'. (Use Ctrl + H to view hidden files/directories).
# I would advise you to inspect this manifest and the one that is cloned below.
#
cd .repo/
echo ""
PS3='Which Device_AndroidVersion would you like to build? (1/2/3/4) '
options=("Star-common Oreo" "Crownlte Oreo" "Universal-9810 Pie" "Other Manifest")
select opt in "${options[@]}"
do
    case $opt in
        "Star-common Oreo")
			echo ""
            echo "You chose '$opt' at Option $REPLY"
            echo ""
			git clone https://github.com/AzzyC/local_manifests.git
# The file brought from cloning this repository will automatically clone repositories required for
# starxxx Device, Kernel and Vendor tree for Oreo. The file is commonly known as a 'roomservice.xml',
# as it fetches everything for you, but it could come under any name.
			echo ""
            break
            ;;
        "Crownlte Oreo")
			echo ""
			echo "You chose '$opt' at Option $REPLY"
			echo ""
            git clone https://github.com/AzzyC/local_manifests-crown.git local_manifests
# To sync Crownlte's Device, Kernel and Vendor Tree instead, at version Oreo. These Trees are sourced from @synt4x93.
# Notice how on this command, local_manifests has been added. This is to direct a path which git should should clone the manfiest
# to, and this is where you should add your own manifests.
            echo ""
            break
            ;;
        "Universal-9810 Pie")
			echo ""
            echo "You chose '$opt' at Option $REPLY"
            echo ""
			git clone https://github.com/AzzyC/local_manifests.git -b lineage-16.0
# Cloning this repository holds the manifest to sync the Device, Kernel and Vendor alpha Pie tree for starxxx and crownlte at the
# state they were at, before they became private. DO NOT report bugs as they are known and most likely fixed in the private
# workings.
# You are expected to use these sources to experiment with an open-mind.
			echo ""
            break
            ;;
        "Other Manifest")
			echo ""
			echo "You chose '$opt' at Option $REPLY"
			echo ""
			echo "No predefined Manifest selected."
			echo "Assuming User has edited/added their Devices Manifest, below this prompt."
# This Option is for the Users that have already edited this script to git clone the manifest for the Device, Kernel, Vendor Tree according
# to their phone. Users can add the command to clone their manifest after this prompt, under 'done', whereby an example has been given (Not 
# one to enable).
			echo ""
            break
            ;;
        *) echo ""
			echo "Invalid: '$REPLY'. You did not choose '1' '2' '3' or '4'! Try again."
			echo ""
			;;
    esac
done
# git clone https://github.com/'yourGitHubName'/'repoNameOfWhereManifestSaved.git local_manifests
#
# This manifest will coincide with the ROM source manifest, when the script reaches the below '$ repo sync ..' command.
# Using these manifests as examples should give you enough knowledge to make your own, for a time of a tree bringup on a
# different device.
#
cd
cd ~/rom/
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --quiet
# This will begin syncing the ROM source and respective device's trees you have enabledusing the manifests (or roomservice) found 
# in the '~/rom/.repo' directory.
# The attached tags should ensure an effective sync e.g. the --force-sync tag is to make sure that if the sync gets interrupted
# or 'sleeps' that it can just pick up wherever it terminated, avoiding a missing a file and causing knock-on errors.
# Otherwise you can simply use: 
#repo sync
# Initially downloading your ROM's source will take a lot of time (factoring in your interent speed also), but if you
# aren't looking to change and build a different ROM's often, then you can simply hit the above command again and it will
# fetch any new updates from the remote source, if there are any. - You do not have to wait for the sync all over again.
while ! [[ $REPLY =~ ^(Y|y|N|n)$ ]]
do
read -p "buildrom.sh: Sync Status: Complete. Are your files ready to compile? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Nn]$ ]]
then
	echo ""
	echo ""
	echo No worries! Simply bash script again, when you are ready.
	echo ""
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
elif [[ ! $REPLY =~ ^[Yy|Nn]$ ]]
	then
		echo ""
		echo ""
		echo "You did not input 'y'/'Y' or 'n'/'N'! Try again."
		echo ""
fi
done
# This prompt is to work as a breaker between the sync and the compile stage, as an opportunity for the user to make file
# changes i.e. modifying the original 'lineage.mk' and contents within, for a ROM that isn't supported by the Device Tree
# If you are absolutely sure that you do not require to change files beyond what is prebuilt on the Device Tree and have
# enabled a lunch command from below, then feel free to disable the prompts functions.
#
# If you have chosen a ROM outside of Device Tree's support then there are a couple of changes to make:
# (This will be done in the example of starlte, change with respect to your device codename star/star2/crown)
#
# 1) In '~/rom/device/samsung/starlte' change the name of the 'lineage.mk' file and rename it to your ROM's needed .mk.
# To keep with above examples of 'PixelExperience', it would need to be renamed to 'aosp_starlte.mk'. 
#
# 2) Opening your renamed *.mk file and you will see lines inhertiting files at the top and then device properties at the bottom.
# So it is sensible to understand that not all ROMs will follow the same folder structure and include the same files and names
# as they have brought ROM source up differently to suit their own.
# The most common line(s) that we should be concerned about is based on when inheriting from 'vendor' folder i.e. '~/rom/vendor'.
# For example inside the original 'lineage.mk' it has an inherit line of 'vendor/lineage/config/..', though in a ROM source like 
# PixelExperience they do not use a folder called 'lineage'. Therefore, we should modify the line to 'vendor/aosp/config/..'.
#
# 3) However, it is not enough to simply rename a filepath at face value, you should go into the '~/rom/vendor' folder and see if
# the filepath holds true/exists and if it is not then of course when compiling you are going to get an error so explore and find
# the file. It may even be that if it doesn't exist then you have to go for a similar target e.g. if there is
# no 'common_full_phone.mk' file then inherit 'common.mk'.
#
# 4) Do compare your *.mk to devices that your chosen ROM officially supports on their GitHub so that you can find missing
# inherits which may be crucial for your ROM e.g. a missing Dialer is never desired.
#
# 5) Finally, now in the bottom section of the *.mk, change the 'PRODUCT_NAME :=' according to your ROMs name.
# For example, for 'PixelExperience' change from 'lineage_starlte' to aosp_starlte'.
#
# Note: If you do not make the changes or correctly based on the instructions below then your compile will be aborted but should
# give you an error to prompt you what to fix.
# Reminding what was mentioned in the first few lines of this script (guide), the script will run from its first command right to
# its last, and if there is any lacking command(s) be prepared to see errors based on the remaining commands as a knock-on effect.
# Also that this script does not terminate unless a user makes it do so, so refrain from dividing blame on the script when it
# comes to a compiling issue.
#
toilet -f smblock "Compile initiated"
. build/envsetup.sh
# This bashes a script tp setup a building workspace i.e. Tools, Paths etc. Validates if you have what is needed to compile.
lunch lineage_starlte-userdebug
# If you have changed to a different ROM source, then your 'lunch' command should be based on your ROM's name e.g. look at
# the example lunch commands below or enable one if it is what you are building.
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
#
# Below is a list of 'lunch' commands that you can enable which the starxxx and crownlte Device Tree support:
#
#lunch aosp_starlte-userdebug
# AEX
#
#lunch lineage_crownlte-userdebug
#lunch aosp_crownlte-userdebug
export LC_ALL=C
# Exposing an environment variable needed for systems above Ubuntu 18.04, This command should avoid compiling errors e.g. reading
# and using makefiles in the correct charset.
make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
#
#mka aex -j$(nproc --all)
# AEX has its own make command. Above comments applies to the '-j' tag too.
#
#brunch rr_starlte-userdebug -j$(nproc --all)
#brunch havoc_starlte-userdebug -j$(nproc --all)
# Havoc and RR can compile with this command right after '. build/envsetup.sh'. Above comments applies to the '-j' tag too.
#
mv ~/rom/out/target/product/starlte/lineage-15.1-*.zip ~/compiled/
mv ~/rom/out/target/product/starlte/lineage-15.1-*.md5sum ~/compiled/
# If you are building a different ROM, it will output a different zip and md5sum file name, so edit accordingly if you would like
# to move the files out and put them into the 'compiled' directory.
# The reason for this move command is to save time going through multiple directories, to grab the compiled ROM but feel free to
# disable if you don't mind.
#
#mv ~/rom/out/target/product/starlte/AospExtended-v5*.zip ~/compiled/
#mv ~/rom/out/target/product/starlte/AospExtended-v5*.md5sum ~/compiled/
# For AEX files.
#
#mv ~/rom/out/target/product/starlte/Havoc-OS-*.zip ~/compiled/
#mv ~/rom/out/target/product/starlte/Havoc-OS-*.md5sum ~/compiled/
# For HavocOS Files.
#
#mv ~/rom/out/target/product/starlte/RR-O-*.zip ~/compiled/
#mv ~/rom/out/target/product/starlte/RR-O-*.md5sum ~/compiled/
# For ResurrectionRemix files.
#
#mv ~/rom/out/target/product/crownlte/lineage-15.1-*.zip ~/compiled/
#mv ~/rom/out/target/product/crownlte/lineage-15.1-*.md5sum ~/compiled/
# If you would like the above comments to occur for crownlte.
#
toilet -f smblock "starlte done"
# To let you know clearly in the terminal that starlte ROM has compiled.
#
#toilet -f smblock "crownlte done"
# To let you know clearly in the terminal that crownlte ROM has compiled.
cd
cd ~/rom/
lunch lineage_star2lte-userdebug
# If you have changed to a different ROM source, then your 'lunch' command should be based on your ROM's name e.g. look at
# the example lunch commands below or enable one if it is what you are building.
# In most cases, it is '$ lunch (romName)_(deviceName)-userdebug'
#
# Below is a list of 'lunch' commands that you can enable which the starxxx and crownlte Device Tree support:
#
#lunch aosp_star2lte-userdebug
#
make bacon -j$(nproc --all)
# This will use all available CPU threads to build, if you do not wish this remove '(nproc --all)' and replace it with
# the number of threads you would like to give to the compile. Example if you have 4 CPU Cores, then you can make 4
# threads using '$ make bacon -j4'
#
#mka aex -j$(nproc --all)
# AEX has its own make command. Above comments applies to the '-j' tag too.
#
#brunch rr_star2lte-userdebug -j$(nproc --all)
#brunch havoc_star2lte-userdebug -j$(nproc --all)
# Havoc and RR can compile with this command right after '. build/envsetup.sh'. Above comments applies to the '-j' tag too.
#
mv ~/rom/out/target/product/star2lte/lineage-15.1-*.zip ~/compiled/
mv ~/rom/out/target/product/star2lte/lineage-15.1-*.md5sum ~/compiled/
# If you are building a different ROM, it will output a different zip and md5sum file name, so edit accordingly if you would like
# to move the files out and put them into the 'compiled' directory.
#
#mv ~/rom/out/target/product/star2lte/AospExtended-v5*.zip ~/compiled/
#mv ~/rom/out/target/product/star2lte/AospExtended-v5*.md5sum ~/compiled/
# For AEX files.
#
#mv ~/rom/out/target/product/starlte/RR-O-*.zip ~/compiled/
#mv ~/rom/out/target/product/starlte/RR-O-*.md5sum ~/compiled/
# For ResurrectionRemix files.
#
#mv ~/rom/out/target/product/star2lte/Havoc-OS-*.zip ~/compiled/
#mv ~/rom/out/target/product/star2lte/Havoc-OS-*.md5sum ~/compiled/
# For HavocOS Files.
#
toilet -f smblock "star2lte done"
# To let you know clearly in the terminal that star2lte ROM has compiled.
cd ~/
if [ -e ".gcloudvncbashed" ]; then
# 'If' GUI exists, from bashing './gcloudvnc.sh'...
x-www-browser https://www.google.com/drive/ https://mega.nz/
# 'then' to open Cloud Storage links, for users to uplaod & download their ROM's.
toilet -f smblock "script passed"
# To let you know clearly in the terminal that the script has finished. and it is safe to close terminal.
fi
while ! [[ $REPLY =~ ^(Y|y|N|n)$ ]] && [ ! -e ".gcloudvncbashed" ]
do
read -p "buildrom.sh: Compile Status: Complete. Would you like to bash './gcloudvnc.sh' to upload your ROM, if you are using a GCloud VM Instance? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo ""
	bash ~/scripts/gcloudvnc.sh
	echo ""
	echo ""
	toilet -f smblock "GCloud VNC started"
	echo ""
elif [[ $REPLY =~ ^[Nn]$ ]]
then
	echo ""
	echo ""
	toilet -f smblock "script passed"
	echo ""
# To let you know clearly in the terminal that the script has finished. and it is safe to close terminal.
else
	echo ""
	echo ""
	echo "You did not input 'y'/'Y' or 'n'/'N'! Try again."
	echo ""
fi
done
