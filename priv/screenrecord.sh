#!/bin/bash

cyan="\u001b[36;1m"
green="\u001b[32;1m"
red="\u001b[31;1m"
white="\u001b[37;1m"
yellow="\u001b[33;1m"

reset="\u001b[0m"

if [[ ! -d "/c/Program Files (x86)/Screen Capturer Recorder/" ]]; then
	printf "\n${yellow}Screen Capture Recorder is not installed\n${green}Downloading latest GitHub release..\n"
	curl -L --progress-bar "$(curl -s https://github.com/rdp/screen-capture-recorder-to-video-windows-free/releases\
								| grep -m1 exe\
								| awk '{print $2}'\
								| sed 's/href="/https:\/\/github.com/;s/"//')"\
								> /c/Users/"$(whoami)"/Downloads/Setup.Screen.Capturer.Recorder.exe
	printf "$white"
	/c/Users/"$(whoami)"/Downloads/Setup.Screen.Capturer.Recorder.exe
	rm -rf "/c/ProgramData/Microsoft/Windows/Start Menu/Programs/Screen Capturer Recorder/"
fi

ffmpeg -loglevel quiet &>/dev/null
if [[ $? -eq 127 ]]; then
	ffmpegver="ffmpeg-n4.3.1-221-gd08bcbffff-win64-gpl-4.3"

	printf "\n${yellow}ffmpeg is not installed\n${green}Downloading latest GitHub release..\n"
	curl -L --progress-bar "$(curl -s https://github.com/BtbN/FFmpeg-Builds/releases\
								| grep -m 1 "$ffmpegver"\
								| awk '{print $2}'\
								| sed 's/href="/https:\/\/github.com/; s/"//')"\
								> /c/Users/"$(whoami)"/Documents/ffmpeg.zip
	printf "$white"
	unzip /c/Users/"$(whoami)"/Documents/ffmpeg.zip -d /c/Users/"$(whoami)"/Documents
	mv /c/Users/"$(whoami)"/Documents/"$ffmpegver" /c/Users/"$(whoami)"/Documents/ffmpeg
	mv /c/Users/"$(whoami)"/Documents/ffmpeg/bin/* /c/Users/"$(whoami)"/Documents/ffmpeg
	rm -rf /c/Users/"$(whoami)"/Documents/ffmpeg/doc /c/Users/"$(whoami)"/Documents/ffmpeg/bin
	export PATH="/c/Users/$(whoami)/Documents/ffmpeg:$PATH"
fi

if [[ ! -d /c/Users/"$(whoami)"/Desktop/ScreenRecord/ ]]; then
	mkdir -p /c/Users/"$(whoami)"/Desktop/ScreenRecord/
	printf "\n${white}All of your recordings will be stored in your Desktop, within 'ScreenRecord'\n"
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
ffmpeg -loglevel warning -stats -guess_layout_max 0 -rtbufsize 200M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t "$time" -c:v libx264 -vsync 2 -r 30 -preset fast -tune zerolatency -crf 30 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y /c/Users/"$(whoami)"/Desktop/ScreenRecord/streaming.mp4

rec_end="$(date +'%a %d-%m-%Y %H:%M:%S')"
file_rec_end="$(echo $rec_end | sed 's/:/-/g')"

printf "\n${red}Recording Ended:${white} $rec_end\n"

printf "\n${yellow}Recording Duration:${white} $(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal /c/Users/"$(whoami)"/Desktop/ScreenRecord/streaming.mp4)\n"

mv /c/Users/"$(whoami)"/Desktop/ScreenRecord/streaming.mp4 /c/Users/"$(whoami)"/Desktop/ScreenRecord/"$file_rec_end".mp4
printf "\n${yellow}Recording Folder Size:${white} $(du -h /c/Users/"$(whoami)"/Desktop/ScreenRecord | awk '{print $1}')B\n ${reset}"

if ! tasklist -v -nh -fi "imagename eq explorer.exe" | grep -q ScreenRecord; then
	explorer.exe \\Users\\"$(whoami)"\\Desktop\\ScreenRecord
fi

explorer.exe \\Users\\"$(whoami)"\\Desktop\\ScreenRecord\\"$file_rec_end".mp4
