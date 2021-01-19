#!/bin/bash
if [[ ! -d "/c/Program Files (x86)/Screen Capturer Recorder/" ]]; then
	printf '%s\n' "Screen Capture Recorder is not installed" "Downloading latest GitHub release.."
	curl -L --progress-bar "$(curl -s https://github.com/rdp/screen-capture-recorder-to-video-windows-free/releases/ | grep -m1 exe | awk '{print $2}' | sed 's/href="/https:\/\/github.com/;s/"//')" > /c/Users/"$(whoami)"/Downloads/Setup.Screen.Capturer.Recorder.exe
	/c/Users/"$(whoami)"/Downloads/Setup.Screen.Capturer.Recorder.exe
	rm -rf "/c/ProgramData/Microsoft/Windows/Start Menu/Programs/Screen Capturer Recorder/"
fi

ffmpeg -loglevel quiet > /dev/null 2>&1
if [[ $? -eq 127 ]]; then
	printf '%s\n' "ffmpeg is not installed" "Downloading latest GitHub release.."
	curl -L --progress-bar "$(curl -s https://github.com/BtbN/FFmpeg-Builds/releases | grep -m 1 ffmpeg-n4.3.1-29-g89daac5fe2-win64-gpl-4.3.zip | awk '{print $2}' | sed 's/href="/https:\/\/github.com/;s/"//')" > /c/Users/"$(whoami)"/Documents/ffmpeg.zip
	unzip /c/Users/"$(whoami)"/Documents/ffmpeg.zip -d /c/Users/"$(whoami)"/Documents
	mv /c/Users/"$(whoami)"/Documents/ffmpeg/bin/* /c/Users/"$(whoami)"/Documents/ffmpeg
	rm -rf /c/Users/"$(whoami)"/Documents/ffmpeg/doc /c/Users/"$(whoami)"/Documents/ffmpeg/bin
	export PATH="/c/Users/"$(whoami)"/Documents/ffmpeg:$PATH"
fi

if [[ ! -d /c/Users/"$(whoami)"/Desktop/ScreenRecord/ ]]; then
	mkdir -p /c/Users/"$(whoami)"/Desktop/ScreenRecord/
	printf '%s\n' "All of your recordings will be stored in your Desktop, within 'ScreenRecord'"
fi

printf '%s\n' "" "Current Max Recording Limit: $(grep audio "${BASH_SOURCE[0]}" | awk '{print $16}')" ""

printf '%s\n' "Recording Started: $(date +'%d-%m-%Y %H:%M:%S')" ""
ffmpeg -loglevel warning -stats -guess_layout_max 0 -rtbufsize 200M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t 02:30:00 -c:v libx264 -vsync 2 -r 30 -preset fast -tune zerolatency -crf 30 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y /c/Users/"$(whoami)"/Desktop/ScreenRecord/streaming.mp4
printf '%s\n' "" "Recording Duration: $(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal /c/Users/"$(whoami)"/Desktop/ScreenRecord/streaming.mp4)" ""

rec_end="$(date +'%a %d-%m-%Y %H.%M.%S')"

printf '%s\n' "Recording Ended: $rec_end" ""

mv /c/Users/"$(whoami)"/Desktop/ScreenRecord/streaming.mp4 /c/Users/"$(whoami)"/Desktop/ScreenRecord/"$rec_end".mp4
printf '%s\n' "Recording Folder Size: $(du -h /c/Users/$(whoami)/Desktop/ScreenRecord | awk '{print $1}')B"

if [[ -z "$(tasklist -v -nh -fi "imagename eq explorer.exe" | grep ScreenRecord)" ]]; then
	explorer.exe \\Users\"$(whoami)\\Desktop\\ScreenRecord
fi

explorer.exe \\Users\"$(whoami)\\Desktop\\ScreenRecord\\"$rec_end".mp4
