#!/bin/bash

cyan="\u001b[36;1m"
green="\u001b[32;1m"
red="\u001b[31;1m"
white="\u001b[37;1m"
yellow="\u001b[33;1m"

reset="\u001b[0m"

user="$(id -un)"

su () {
	if ! net session &> /dev/null; then
		printf "\n${red}User Privileges Only\nWill not be able to install required programs\n\
		\rPlease right-click on 'git-bash' application and 'Run as administrator'\n\nNo actions were done!\nExiting..\n"
		exit 0
	fi
}

ffmpegcheck () {
	if [[ $? -eq 127 ]]; then
		ffmpegver="ffmpeg-n4.3.1-221-gd08bcbffff-win64-gpl-4.3"

		printf "\n${yellow}ffmpeg is not installed\n${green}Downloading latest GitHub release..\n"
		curl -L --progress-bar "$(curl -s https://github.com/BtbN/FFmpeg-Builds/releases\
									| grep -m 1 "$ffmpegver"\
									| awk '{print $2}'\
									| sed 's/href="/https:\/\/github.com/; s/"//')"\
									> /c/Users/"$user"/Documents/ffmpeg.zip
		printf "$white"
		unzip /c/Users/"$user"/Documents/ffmpeg.zip -d /c/Users/"$user"/Documents
		mv /c/Users/"$user"/Documents/"$ffmpegver" /c/Users/"$user"/Documents/ffmpeg
		mv /c/Users/"$user"/Documents/ffmpeg/bin/* /c/Users/"$user"/Documents/ffmpeg
		rm -rf /c/Users/"$user"/Documents/ffmpeg/doc /c/Users/"$user"/Documents/ffmpeg/bin
		export PATH="/c/Users/$user/Documents/ffmpeg:$PATH"
	fi
}

if [[ ! -d /c/Users/"$user"/Documents/ScreenRecordLibs/ ]]; then
	mkdir -p /c/Users/"$user"/Documents/ScreenRecordLibs/
	printf "\n${white}Libs required for Screen Recording will be stored in /c/Users/$user/Documents/ScreenRecordLibs\n"
fi

if [[ -z "$(ffmpeg -hide_banner -list_devices true -f dshow -i dummy 2> >(grep screen-capture))" ]]; then
	ffmpegcheck
	printf "\n${yellow}screen-capture-recorder lib is not installed\n${green}Downloading latest..\n"
	su
	curl -L --progress-bar "https://github.com/ShareX/ShareX/blob/master/Lib/screen-capture-recorder-x64.dll?raw=true"\
	> /c/Users/"$user"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
	regsvr32 /c/Users/"$user"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
fi

if [[ -z "$(ffmpeg -hide_banner -list_devices true -f dshow -i dummy 2> >(grep virtual-audio))" ]]; then
	ffmpegcheck
	su
	printf "\n${yellow}virtual-audio-capturer lib is not installed\n${green}Downloading latest..\n"
	curl -L --progress-bar "https://github.com/ShareX/ShareX/blob/master/Lib/virtual-audio-capturer-x64.dll?raw=true"\
	> /c/Users/"$user"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
	regsvr32 /c/Users/"$user"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
fi

if [[ ! -e /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh ]]; then
	touch /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
	printf '#!/bin/bash\n#bash /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh - To remove Screen Recorder libs and from registry
# Need a d m i n, otherwise will n o t uninstalll p r o p e r l y!

regsvr32 -u /c/Users/"$user"/Documents/ScreenRecordLibs/screen-capture-recorder-x64.dll
regsvr32 -u /c/Users/"$user"/Documents/ScreenRecordLibs/virtual-audio-capturer-x64.dll
rm -rf /c/Users/"$user"/Documents/ScreenRecordLibs/
'\
	> /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
	chmod +x /c/Users/"$user"/Documents/ScreenRecordLibs/uninstalllibs.sh
fi

if [[ ! -d /c/Users/"$user"/Desktop/ScreenRecord/ ]]; then
	mkdir -p /c/Users/"$user"/Desktop/ScreenRecord/
	printf "\n${white}All recordings will be stored in /c/Users/$user/Desktop/ScreenRecord\n"
fi

if [ -n "$1" ]; then
	time="$1"
else
	time="02:15:00"
fi

if [[ "$time" == *":"* ]]; then
	H="$(printf "$time" | cut -d ':' -f1) Hour(s) "
	M="$(printf "$time" | cut -d ':' -f2) Minute(s) "
	S="$(printf "$time" | cut -d ':' -f3) Second(s)"

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

printf "\n${yellow}Current Max Recording Limit:${white} ${H}${M}${S}\n"

printf "\n${green}Recording Started:${white} $(date +'%d-%m-%Y %H:%M:%S')\n\n${cyan}"
ffmpeg -loglevel warning -stats -guess_layout_max 0 -rtbufsize 200M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t "$time" -c:v libx264 -vsync 2 -r 30 -preset fast -tune zerolatency -crf 30 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y /c/Users/"$user"/Desktop/ScreenRecord/streaming.mp4

rec_end="$(date +'%a %d-%m-%Y %H:%M:%S')"
file_rec_end="$(echo $rec_end | sed 's/:/-/g')"

printf "\n${red}Recording Ended:${white} $rec_end\n"

printf "\n${yellow}Recording Duration:${white} $(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal /c/Users/"$user"/Desktop/ScreenRecord/streaming.mp4)\n"

mv /c/Users/"$user"/Desktop/ScreenRecord/streaming.mp4 /c/Users/"$user"/Desktop/ScreenRecord/"$file_rec_end".mp4
printf "\n${yellow}Recording Folder Size:${white} $(du -h /c/Users/"$user"/Desktop/ScreenRecord | awk '{print $1}')B\n ${reset}"

if ! tasklist -v -nh -fi "imagename eq explorer.exe" | grep -q ScreenRecord; then
	explorer.exe \\Users\\"$user"\\Desktop\\ScreenRecord
fi

explorer.exe \\Users\\"$user"\\Desktop\\ScreenRecord\\"$file_rec_end".mp4
