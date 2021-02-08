#!/bin/bash

cyan="\u001b[36;1m"
green="\u001b[32;1m"
red="\u001b[31;1m"
white="\u001b[37;1m"
yellow="\u001b[33;1m"
reset="\u001b[0m"

user="$(id -un)"

alias fetch='bash <<< "$(curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch)"'
alias clear='clear -x'
alias desk='explorer.exe \\Users\\"$user"\\Desktop'
alias doc='explorer.exe \\Users\\"$user"\\Documents'
alias down='explorer.exe \\Users\\"$user"\\Downloads'
alias hades='bash <<< "$(curl -s https://del.dog/raw/hadesqissues)"'
alias pray='bash /c/Users/$user/Documents/scripts/priv/masjidtime.sh'
alias rec='bash /c/Users/$user/Documents/scripts/priv/screenrecord.sh'
alias user='explorer.exe \\Users\\"$user"'

crop () {
	ffmpegcheck
	inputfile="$(printf "$1" | sed 's/'\''//g')"
	read -r -p "Timestamp of where to begin new video [HH:MM:SS] [00:00:00]: " begin
	printf '%s\n' ""
	read -r -p "Timestamp of where to end new video [HH:MM:SS] [00:00:00]: " end
	printf '%s\n' ""
	read -r -p "Name of cropped video: " outputfile
	printf "\n${cyan}"

	mkdir -p /c/Users/"$user"/Desktop/ScreenRecord/
	ffmpeg -loglevel warning -stats -i "$inputfile" -ss "$begin" -to "$end" -c:v libx264 -vsync 2 -y /c/Users/"$user"/Desktop/ScreenRecord/"$outputfile".mp4
	printf "\n${yellow}File saved: /c/Users/$user/Desktop/ScreenRecord/${outputfile}.mp4${reset}\n"
	explorer.exe \\Users\\"$user"\\Desktop\\ScreenRecord\\"$outputfile".mp4
}

ffmpegcheck () {
	ffmpeg -loglevel quiet &>/dev/null
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

PS1='\[\033]0;$PWD\007\]\n\[\033[0;92m\]\u \[\033[0;95m\]\w \[\033[1;97m\]\[\033[41m\] \D{%a %d} \[\033[44m\] \t \[\033[0m\]\n\$ '

src () {
	source /etc/bash.bashrc
	printf "\n${yellow}b${cyan}a${yellow}s${red}h${white}rc ${cyan}s${yellow}o${green}u${red}r${white}c${yellow}e${cyan}d!${reset}\n"
}

ss () {
	ffmpegcheck
	printf "\n"
	inputfile="$(printf "$1" | sed 's/'\''//g')"
	read -r -p "Video timestamps to be screenshotted [HH:MM:SS] [00:00:00]: " -a stamps
	printf "\n${cyan}"
	mkdir -p /c/Users/"$user"/Desktop/ScreenRecord/

	i=1
	for stamp in "${stamps[@]}"; do
	ffmpeg -loglevel quiet -stats -ss "$stamp" -i "$inputfile" -vframes 1 -q:v 1 -y /c/Users/"$user"/Desktop/ScreenRecord/"$i".png
	i="$((i+1))"
	done

	printf "${reset}"
}

su () {
	if net session &> /dev/null; then
		printf "\n${green}Administrative Privileges${reset}\n"
	else
		printf "\n${red}User Privileges${reset}\n"
	fi
}

ytaudio () {
	ytcheck
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
