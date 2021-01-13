clear
printf "Current Max Recording Limit: $(grep audio "${BASH_SOURCE[0]}" | awk '{print $16}')\n"

printf "\nRecording Started: $(date '+%d-%m-%Y %H:%M:%S')\n\n"
ffmpeg -loglevel warning -stats -guess_layout_max 0 -rtbufsize 150M -f dshow -framerate 30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -t 02:30:00 -c:v libx264 -r 30 -preset veryfast -tune zerolatency -crf 28 -pix_fmt yuv420p -movflags +faststart -c:a aac -ac 2 -b:a 128k -y ~/Desktop/ScreenRecord/streaming.mp4
printf "\nRecording Duration: $(ffprobe -v quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -sexagesimal ~/Desktop/ScreenRecord/streaming.mp4)\n"
printf "\nRecording Ended: $(date '+%d-%m-%Y %H.%M.%S')\n"

mv ~/Desktop/ScreenRecord/streaming.mp4 ~/Desktop/ScreenRecord/"$(date '+%d-%m-%Y %H.%M.%S')".mp4
