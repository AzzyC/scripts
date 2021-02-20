#!/bin/bash

cyan="\u001b[36;1m"
green="\u001b[32;1m"
red="\u001b[31;1m"
white="\u001b[37;1m"
yellow="\u001b[33;1m"

PATH="/c/Users/$USERNAME/Documents/ffmpeg:$PATH"
linuxbashdir="$(sed 's/C:/\/c/; s/\\/\//g' <<< $EXEPATH)"

if ! net session &> /dev/null; then
	PS1='\[\033]0;$PWD\007\]\n\[\033[1;97m\]\[\033[41m\] \D{%a %d} \[\033[44m\] \t \[\033[0m\] \[\033[0;92m\][azzy \[\033[0;95m\]\w] \[\033[0m\]➤ '
else
	PS1='\[\033]0;admin: $PWD\007\]\n\[\033[1;97m\]\[\033[41m\] \D{%a %d} \[\033[44m\] \t \[\033[0m\] \[\033[0;91m\][admin@\[\033[0;92m\]azzy \[\033[0;95m\]\w] \[\033[0m\]➤ '
	cd /
	schtasks -create -tn "git-bash-admin" -sc ONCE -st 01:09 -tr "$EXEPATH\git-bash-admin.exe" -f -rl HIGHEST &> /dev/null
fi

PS2='➤➤ '

alias clear='clear -x'
alias desk='explorer.exe \\Users\\"$USERNAME"\\Desktop'
alias diff='git diff --color=always 2>&1 | sed "/^warning: /d; /^The file/d"'
alias doc='explorer.exe \\Users\\"$USERNAME"\\Documents'
alias down='explorer.exe \\Users\\"$USERNAME"\\Downloads'
alias fetch='bash <<< "$(curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch)"'
alias hades='bash <<< "$(curl -s https://del.dog/raw/hadesqissues)"'
alias nosleep='bash /c/Users/"$USERNAME"/Documents/scripts/nosleep.sh'
alias nosleeprec='bash /c/Users/"$USERNAME"/Documents/scripts/nosleep.sh bash /c/Users/"$USERNAME"/Documents/scripts/priv/screenrecord.sh'
alias pray='bash /c/Users/"$USERNAME"/Documents/scripts/priv/masjidtime.sh'
alias rec='bash /c/Users/"$USERNAME"/Documents/scripts/priv/screenrecord.sh'
alias user='explorer.exe \\Users\\"$USERNAME"'

admin () {
	cp -n "$linuxbashdir"/git-bash.exe "$linuxbashdir"/git-bash-admin.exe
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "$EXEPATH\git-bash-admin.exe" -t REG_SZ -d RUNASADMIN -f 1> /dev/null
	if ! schtasks -run -i -tn "git-bash-admin" &> /dev/null; then
		explorer "$EXEPATH"\\git-bash-admin.exe
	fi
}

crop () {
	ffmpegcheck
	inputfile="$(printf "$1" | sed 's/'\''//g')"
	read -r -p "Timestamp of where to begin new video [HH:MM:SS] [00:00:00]: " begin
	printf '%s\n' ""
	read -r -p "Timestamp of where to end new video [HH:MM:SS] [00:00:00]: " end
	printf '%s\n' ""
	read -r -p "Name of cropped video: " outputfile
	printf "\n${cyan}"

	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/
	ffmpeg -loglevel warning -stats -i "$inputfile" -ss "$begin" -to "$end" -c:v libx264 -vsync 2 -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$outputfile".mp4
	printf "\n${yellow}File saved: /c/Users/$USERNAME/Desktop/ScreenRecord/${outputfile}.mp4\n"
	explorer.exe \\Users\\"$USERNAME"\\Desktop\\ScreenRecord\\"$outputfile".mp4
}

ffmpegcheck () {
	ffmpeg -loglevel quiet 2> /dev/null
	if [[ $? -eq 127 ]]; then
		echo -e "\n${yellow}ffmpeg is not installed\n${green}Downloading latest.."
		curl -L --progress-bar "$(curl -s https://github.com/GyanD/codexffmpeg/releases\
									| grep -m 1 'essentials.*zip'\
									| awk '{print $2}'\
									| sed 's/href="/https:\/\/github.com/; s/"//')"\
									> /c/Users/"$USERNAME"/Documents/temp.zip
		unzip -q /c/Users/"$USERNAME"/Documents/temp.zip -d /c/Users/"$USERNAME"/Documents/ && rm /c/Users/"$USERNAME"/Documents/temp.zip
		mv /c/Users/"$USERNAME"/Documents/ffmpeg-*/bin /c/Users/"$USERNAME"/Documents/ffmpeg && rm -rf /c/Users/"$USERNAME"/Documents/ffmpeg-*/
		reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "C:\Users\\${USERNAME}\Documents\ffmpeg\ffmpeg.exe" -t REG_SZ -d HIGHDPIAWARE -f 1> /dev/null
	fi
}

history () {
	builtin history -a | cat -$1 ~/.bash_history 2> /dev/null
}

src () {
	source /etc/bash.bashrc
	printf "\n${yellow}b${cyan}a${yellow}s${red}h${white}rc ${cyan}s${yellow}o${green}u${red}r${white}c${yellow}e${cyan}d!\n"
}

ss () {
	ffmpegcheck
	printf "\n"
	inputfile="$(printf "$1" | sed 's/'\''//g')"
	read -r -p "Video timestamps to be screenshotted [HH:MM:SS] [00:00:00]: " -a stamps
	printf "\n${cyan}"
	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/

	i=1
	for stamp in "${stamps[@]}"; do
	ffmpeg -loglevel quiet -stats -ss "$stamp" -i "$inputfile" -vframes 1 -q:v 1 -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$i".png
	i="$((i+1))"
	done
}

weather () {
	curl -s "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/2643123" \
		| grep -m 1 "pub" \
		| sed "s/   *//g; s/<pubDate>/\nLast Updated: /; s/<\/.*/\n/"
	curl -s "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/2643123" \
		| grep -E "(To|title|description|pub)" \
		| sed "s/Â//g; s/<pub.*//g; s/<[^>]*>//g; s/   *//g; 1,4d; s/Wind D.*Wind/Wind/g; s/Press.*Hum/Hum/g ; s/UV.*Pol/Pol/g; s/Sunrise/\nSunrise/g"
}

ytaudio () {
	ytcheck
	echo -e "First Paramter - Audio Format: 'flac' or 'best'"
	youtube-dl.exe -x --audio-format $1 $2 $3 $4 $5 $6
}

ytcheck () {
	youtube-dl.exe --version &>/dev/null

	if [[ "$?" -eq 127 ]]; then
		printf "\n${yellow}youtube-dl is not installed\n${green}Downloading latest GitHub release..\n${white}"
		curl -L --progress-bar -o /usr/bin/youtube-dl.exe "$(curl -s https://github.com/ytdl-org/youtube-dl/releases\
																| grep -m1 youtube-dl.exe\
																| awk '{print $2}'\
																| sed 's/href="/https:\/\/github.com/; s/"//g')"
	fi
}

ytdl () {
	ytcheck
	youtube-dl.exe $1 $2 $3 $4 $5 $6
}
