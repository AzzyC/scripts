printf "Recording Started: $(date '+%d/%m/%Y %H:%M:%S')\n"
ffmpeg -loglevel quiet -rtbufsize 150M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t 30 -c:v libx264 -r 30 -preset veryfast -tune zerolatency -crf 28 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y ~/Desktop/ScreenRecord/testing.mp4 >/dev/null
printf "\nRecording Duration: $(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal ~/Desktop/ScreenRecord/testing.mp4)\n"
printf "\nRecording Ended: $(date '+%d/%m/%Y %H:%M:%S')\n"
