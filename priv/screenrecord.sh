#!/bin/bash

cyan="\u001b[36;1m"
green="\u001b[32;1m"
red="\u001b[31;1m"
white="\u001b[37;1m"
yellow="\u001b[33;1m"

if [[ "$OS" != *Windows* ]]; then
	echo -e "\n${red}This script only works on Windows\e\!"
	exit 1
fi

PATH="/c/Users/$USERNAME/Documents/ffmpeg:$PATH"
linuxbashdir="$(sed 's/C:/\/c/; s/\\/\//g' <<< "$EXEPATH")"

su () {
	if ! net session &> /dev/null; then
		echo -e "\n${red}User Privileges Only\nWill not be able to install required programs\n\
		\rPlease bash script again in the new terminal window, which has Administrator Privileges\n\nNo actions taken\e\!\nExiting.."
		cp -n "$linuxbashdir"/git-bash.exe "$linuxbashdir"/git-bash-admin.exe
		reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "$EXEPATH\git-bash-admin.exe" -t REG_SZ -d RUNASADMIN -f 1> /dev/null
		sleep 3
		if ! schtasks -run -i -tn "git-bash-admin" &> /dev/null; then
			explorer "$EXEPATH"\\git-bash-admin.exe
		fi
		exit 1
	else
		schtasks -create -tn "git-bash-admin" -sc ONCE -st 01:09 -tr "$EXEPATH\git-bash-admin.exe" -f -rl HIGHEST &> /dev/null
	fi
}

ffmpeg -loglevel quiet 2> /dev/null
if [[ "$?" -eq 127 ]]; then
	echo -e "\n${yellow}ffmpeg is not installed\n${green}Downloading latest.."
	curl -L --progress-bar "$(curl -s https://github.com/GyanD/codexffmpeg/releases\
								| grep -m 1 'essentials.*zip'\
								| awk '{print $2}'\
								| sed 's/href="/https:\/\/github.com/; s/"//')"\
								> /c/Users/"$USERNAME"/Documents/temp.zip
	unzip -q /c/Users/"$USERNAME"/Documents/temp.zip -d /c/Users/"$USERNAME"/Documents/ && rm /c/Users/"$USERNAME"/Documents/temp.zip
	mv /c/Users/"$USERNAME"/Documents/ffmpeg-*/bin /c/Users/"$USERNAME"/Documents/ffmpeg && rm -rf /c/Users/"$USERNAME"/Documents/ffmpeg-*/
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "C:\Users\\${USERNAME}\Documents\ffmpeg\ffmpeg.exe" -t REG_SZ -d HIGHDPIAWARE -f 1> /dev/null
	echo -e "ffmpeg installed"
fi

if [[ ! -d /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/ ]]; then
	echo -e "\n${yellow}Libs downloaded for Screen Recording will be stored in:${white} C:\Users\\\\${USERNAME}\Documents\ScreenRecordLibs"
fi

if [ ! -e /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/uninstalllibs.sh ]; then
	mkdir -p /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/
	attrib +h "C:\Users\\$USERNAME\Documents\ScreenRecordLibs"
	echo -nE "#!/bin/bash
#bash /c/Users/$USERNAME/Documents/ScreenRecordLibs/uninstalllibs.sh
# - To remove Screen Recorder libs and from registry

if ! net session &> /dev/null; then
	echo -e \"\n${red}User Privileges Only\nWill not be able to unregister libraries\n
	\rPlease bash script again in the new terminal window, which has Administrator Privileges\n\nNo actions taken!\nExiting..\u001b[0m\"
	cp -n $linuxbashdir/git-bash.exe $linuxbashdir/git-bash-admin.exe
	reg add \"HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\" -v \"$EXEPATH\git-bash-admin.exe\" -t REG_SZ -d RUNASADMIN -f 1> /dev/null
	sleep 3
	if ! schtasks -run -i -tn \"git-bash-admin\" &> /dev/null; then
		explorer $(cd / && pwd -W | sed 's/\//\\/g; s/\\/\\\\/g; s/C://')\\\\git-bash-admin.exe
	fi
	exit 1
else
	schtasks -create -tn \"git-bash-admin\" -sc ONCE -st 01:09 -tr \"$EXEPATH\\git-bash-admin.exe\" -f -rl HIGHEST &> /dev/null
fi

#regsvr32 -u /c/Users/$USERNAME/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
#regsvr32 -u /c/Users/$USERNAME/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
rm -rf /c/Users/$USERNAME/Documents/ScreenRecordLibs/
"\
	> /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/uninstalllibs.sh
	chmod +x /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/uninstalllibs.sh
fi

rec_devices="$(ffmpeg -hide_banner -list_devices true -f dshow -i dummy 2>&1)"

if ! grep -q 'screen-capture' <<< "$rec_devices"; then
	echo -e "\n${yellow}'screen-capture-recorder' lib is not installed"
	su
	echo -e "${green}Downloading.."
	curl -L --progress-bar "https://github.com/ShareX/ShareX/blob/master/Lib/screen-capture-recorder-x64.dll?raw=true"\
	> /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
	regsvr32 -s /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
	sed -i '19s/#//' /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/uninstalllibs.sh
	echo -e "'screen-capture-recorder' lib installed"
fi

if ! grep -q 'virtual-audio' <<< "$rec_devices"; then
	echo -e "\n${yellow}'virtual-audio-capturer' lib is not installed"
	su
	echo -e "${green}Downloading.."
	curl -L --progress-bar "https://github.com/ShareX/ShareX/blob/master/Lib/virtual-audio-capturer-x64.dll?raw=true"\
	> /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
	regsvr32 -s /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll 1> /dev/null
	sed -i '20s/#//' /c/Users/"$USERNAME"/Documents/ScreenRecordLibs/uninstalllibs.sh
	echo -e "'virtual-audio-capturer' lib installed"
fi

if [ ! -d /c/Users/"$USERNAME"/Desktop/ScreenRecord/ ]; then
	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/
	echo -e "\n${yellow}All recordings will be stored in:${white} C:\Users\\\\${USERNAME}\Desktop\ScreenRecord"
fi

if [ -n "$1" ]; then
	time="$1"
else
	time="02:15:00"
fi

if [[ "$time" == *":"* ]]; then
	H="$(cut -d ':' -f1 <<< "$time") Hour(s) "
	M="$(cut -d ':' -f2 <<< "$time") Minute(s) "
	S="$(cut -d ':' -f3 <<< "$time") Second(s)"

	if [[ "$H" =~ "00" ]]; then
		unset H
	fi
	if [[ "$M" =~ "00" ]]; then
		unset M
	fi
	if [[ "$S" =~ "00" ]]; then
		unset S
	fi

else
	S="$time Second(s)"
fi

echo -e "\n${yellow}Recording Limit:${white} ${H}${M}${S}\n\n\
\
${green}Script Started:${white} $(date +'%d-%m-%Y %H:%M:%S')\n${cyan}"
ffmpeg -loglevel warning -stats -guess_layout_max 0 -rtbufsize 200M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t "$time" -c:v libx264 -vsync 2 -r 30 -preset fast -tune zerolatency -crf 30 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/streaming.mp4

rec_end="$(date +'%a %d-%m-%Y %H:%M:%S')"
file_rec_end="$(sed 's/:/-/g' <<< "$rec_end")"

mv /c/Users/"$USERNAME"/Desktop/ScreenRecord/streaming.mp4 /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$file_rec_end".mp4

echo -e "\n${red}Recording Ended:${white} $rec_end\n\n\
\
${yellow}Recording Duration:${white} \
$(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$file_rec_end".mp4)\n\
\
${yellow}File saved as:${white} C:\Users\\\\${USERNAME}\Desktop\ScreenRecord\\${file_rec_end}.mp4\n\
\
${yellow}Recording${cyan}/${yellow}Folder Size:${white} $(du -h /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$file_rec_end".mp4 | awk '{print $1}')B out of \
$(du -h /c/Users/"$USERNAME"/Desktop/ScreenRecord | awk '{print $1}')B"

while [[ ! "$action" =~ ^(D|d|N|n)$ ]]; do
	echo -ne "\n${green}What would you like to do with the recording now?\nNothing, Open, Rename, Delete (n/O/r/D): "
	read -r -n 2 action

	if [[ "$action" =~ ^[Oo]$ ]]; then
		if ! tasklist -v -nh -fi "imagename eq explorer.exe" | grep -q ScreenRecord; then
			explorer \\Users\\"$USERNAME"\\Desktop\\ScreenRecord
		fi
		explorer \\Users\\"$USERNAME"\\Desktop\\ScreenRecord\\"$file_rec_end".mp4
	fi

	if [[ "$action" =~ ^[Rr]$ ]]; then
		echo -ne "\n${green}Rename file to: "
		read -r rename
		rename="$(sed 's/\\//g; s/\///g; s/://g; s/*//g; s/?//g; s/"//g; s/<//g; s/>//g; s/|//g' <<< "$rename")"

		if mv -n /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$file_rec_end".mp4 /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$rename".mp4 2> /dev/null; then
			if [ -e /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$file_rec_end".mp4 ]; then
				echo -e "${red}File not renamed: '$rename' already exists"
			else
				file_rec_end="$rename"
				echo -ne "${yellow}File saved as:${white} "
				echo -E "C:\Users\\${USERNAME}\Desktop\ScreenRecord\\${file_rec_end}.mp4"
			fi
		else
			echo -e "${red}File not renamed: '$file_rec_end' is currently open"
		fi

	fi

	if [[ "$action" =~ ^[Dd]$ ]]; then
		echo -ne "\n$red"
		rm -v /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$file_rec_end".mp4
	fi

	if [[ ! "$action" =~ ^[Oo|Dd|Nn|Rr]$ ]]; then
		echo -e "\n${red}You did not input 'o'/'O', 'd'/'D' or 'n'/'N'! Try again."
	fi
done

echo -e "\u001b[0m"
