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

user="$(id -un)"
PATH="/c/Users/$user/Documents/ffmpeg:$PATH"

su () {
	if ! net session &> /dev/null; then
		echo -e "\n${red}User Privileges Only\nWill not be able to install required programs\n\
		\rPlease right-click on 'git-bash' application and 'Run as administrator'\n\nNo actions taken\e\!\nExiting.."
		exit 1
	fi
}

ffmpegcheck () {
	ffmpeg -loglevel quiet 2> /dev/null
	if [[ $? -eq 127 ]]; then
		echo -e "\n${yellow}ffmpeg is not installed\n${green}Downloading latest.."
		curl -L --progress-bar "$(curl -s https://github.com/GyanD/codexffmpeg/releases\
									| grep -m 1 'essentials.*zip'\
									| awk '{print $2}'\
									| sed 's/href="/https:\/\/github.com/; s/"//')"\
									> /c/Users/"$user"/Documents/temp.zip
		unzip -q /c/Users/"$user"/Documents/temp.zip -d /c/Users/"$user"/Documents/ && rm /c/Users/"$user"/Documents/temp.zip
		mv /c/Users/"$user"/Documents/ffmpeg-*/bin /c/Users/"$user"/Documents/ffmpeg && rm -rf /c/Users/"$user"/Documents/ffmpeg-*/
		reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "C:\Users\\${user}\Documents\ffmpeg\ffmpeg.exe" -t REG_SZ -d HIGHDPIAWARE -f 1> /dev/null
	fi
}

if [[ ! -d /c/Users/"$user"/Documents/ScreenRecordLibs/ ]]; then
	echo -e "\n${yellow}Libs downloaded for Screen Recording will be stored in:${white} /c/Users/$user/Documents/ScreenRecordLibs"
fi

if ! ffmpeg -hide_banner -list_devices true -f dshow -i dummy 2>&1 | grep -q 'screen-capture'; then
	ffmpegcheck
	echo -e "\n${yellow}'screen-capture-recorder' lib is not installed"
	su
	echo -e "${green}Downloading.."
	mkdir -p /c/Users/"$user"/Documents/ScreenRecordLibs/
	curl -L --progress-bar "https://github.com/ShareX/ShareX/blob/master/Lib/screen-capture-recorder-x64.dll?raw=true"\
	> /c/Users/"$user"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
	regsvr32 -s /c/Users/"$user"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
fi

if ! ffmpeg -hide_banner -list_devices true -f dshow -i dummy 2>&1 | grep -q 'virtual-audio'; then
	ffmpegcheck
	echo -e "\n${yellow}'virtual-audio-capturer' lib is not installed"
	su
	echo -e "${green}Downloading.."
	mkdir -p /c/Users/"$user"/Documents/ScreenRecordLibs/
	curl -L --progress-bar "https://github.com/ShareX/ShareX/blob/master/Lib/virtual-audio-capturer-x64.dll?raw=true"\
	> /c/Users/"$user"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
	regsvr32 -s /c/Users/"$user"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll 1> /dev/null
fi

if [[ ! -e /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh ]]; then
	touch /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
	echo -nE "#!/bin/bash
#bash /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
# - To remove Screen Recorder libs and from registry

if ! net session &> /dev/null; then
	echo -e \"\n\u001b[31;1mUser Privileges Only\nWill not be able to unregister libraries\n
	\rPlease right-click on 'git-bash' application and 'Run as administrator'\n\nNo actions taken!\nExiting..\"
	exit 1
fi

regsvr32 -u /c/Users/"$user"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
regsvr32 -u /c/Users/"$user"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
rm -rf /c/Users/"$user"/Documents/ScreenRecordLibs/
"\
	> /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
	chmod +x /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
fi

if [[ ! -d /c/Users/"$user"/Desktop/ScreenRecord/ ]]; then
	mkdir -p /c/Users/"$user"/Desktop/ScreenRecord/
	echo -e "\n${yellow}All recordings will be stored in:${white} /c/Users/$user/Desktop/ScreenRecord"
fi

if [ -n "$1" ]; then
	time="$1"
else
	time="02:15:00"
fi

if [[ "$time" == *":"* ]]; then
	H="$(echo -n "$time" | cut -d ':' -f1) Hour(s) "
	M="$(echo -n "$time" | cut -d ':' -f2) Minute(s) "
	S="$(echo -n "$time" | cut -d ':' -f3) Second(s)"

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

echo -ne "\n${yellow}Current Max Recording Limit:${white} ${H}${M}${S}\n\n\
\
${green}Script Started:${white} $(date +'%d-%m-%Y %H:%M:%S')\n\n${cyan}"
ffmpeg -loglevel warning -stats -guess_layout_max 0 -rtbufsize 200M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t "$time" -c:v libx264 -vsync 2 -r 30 -preset fast -tune zerolatency -crf 30 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y /c/Users/"$user"/Desktop/ScreenRecord/streaming.mp4

rec_end="$(date +'%a %d-%m-%Y %H:%M:%S')"
file_rec_end="$(echo -n "$rec_end" | sed 's/:/-/g')"

echo -e "\n${red}Recording Ended:${white} $rec_end\n\n\
\
${yellow}Recording Duration:${white} \
$(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal /c/Users/"$user"/Desktop/ScreenRecord/streaming.mp4)\n\
\
${yellow}File saved as:${white} /c/Users/$user/Desktop/ScreenRecord/${file_rec_end}.mp4\n\
\
${yellow}Recording Folder Size:${white} $(du -h /c/Users/"$user"/Desktop/ScreenRecord | awk '{print $1}')B"

mv /c/Users/"$user"/Desktop/ScreenRecord/streaming.mp4 /c/Users/"$user"/Desktop/ScreenRecord/"$file_rec_end".mp4

if ! tasklist -v -nh -fi "imagename eq explorer.exe" | grep -q ScreenRecord; then
	explorer \\Users\\"$user"\\Desktop\\ScreenRecord
fi

explorer \\Users\\"$user"\\Desktop\\ScreenRecord\\"$file_rec_end".mp4
