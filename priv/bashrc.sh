#!/bin/bash

if ! grep -q bashrc.sh /etc/bash.bashrc; then
	echo -e "\nsource /c/Users/$USERNAME/Documents/scripts/priv/bashrc.sh\
	|| source <(curl -s 'https://raw.githubusercontent.com/AzzyC/scripts/main/priv/bashrc.sh')" \
	>> /etc/bash.bashrc
fi

cyan="\u001b[36;1m"
green="\u001b[32;1m"
red="\u001b[31;1m"
white="\u001b[37;1m"
yellow="\u001b[33;1m"
reset="\u001b[0m"

PATH="/c/Users/$USERNAME/Documents/ffmpeg:$PATH"

HISTCONTROL='erasedups'
HISTFILESIZE='3000'
HISTSIZE='3000'
HISTTIMEFORMAT="[%a %d %T] "
shopt -s histappend

if ! net session &> /dev/null; then
	PS1='\[\033]0;$PWD\007\]\n 🡡 \[\033[1;97m\]\[\033[41m\] \D{%a %d} \[\033[44m\] \t \[\033[0m\]\n\[\033[0;92m\][azzy \[\033[0;95m\]\w] \[\033[0m\]➤ '
else
	PS1='\[\033]0;admin: $PWD\007\]\n 🡡 \[\033[1;97m\]\[\033[41m\] \D{%a %d} \[\033[44m\] \t \[\033[0m\]\n\[\033[0;91m\][admin@\[\033[0;92m\]azzy \[\033[0;95m\]\w] \[\033[0m\]➤ '
	cd /
	schtasks -create -tn "git-bash-admin" -sc ONCE -st 01:09 -tr "$EXEPATH\git-bash-admin.exe" -f -rl HIGHEST &> /dev/null
	reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Open Git-Bash here\command" -d "$EXEPATH\git-bash.exe" -t REG_SZ -f 1> /dev/null
fi

PS0=' 🡣 \[\033[1;97m\]\[\033[41m\] \D{%a %d} \[\033[44m\] \t \[\033[0m\]\n'
PS2='➤➤ '

alias c='clear'
alias desk='explorer.exe \\Users\\"$USERNAME"\\Desktop'
alias diff='git diff --color=always 2>&1 | sed "/^warning: /d; /^The file/d"'
alias doc='explorer.exe \\Users\\"$USERNAME"\\Documents'
alias down='explorer.exe \\Users\\"$USERNAME"\\Downloads'
alias fetch='bash <(curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch)'
alias gitlog='git log --pretty=format:"%h - %an, %ar | %s" | fzy -l 25 -p "Search commit history: "'
alias hades='bash <(curl -s https://del.dog/raw/hadesqissues)'
alias nosleep='bash /c/Users/"$USERNAME"/Documents/scripts/nosleep.sh'
alias nosleeprec='bash /c/Users/"$USERNAME"/Documents/scripts/nosleep.sh bash /c/Users/"$USERNAME"/Documents/scripts/priv/screenrecord.sh'
alias pray='bash /c/Users/"$USERNAME"/Documents/scripts/priv/masjidtime.sh || bash <(curl -s https://raw.githubusercontent.com/AzzyC/scripts/main/priv/masjidtime.sh)'
alias rec='bash /c/Users/"$USERNAME"/Documents/scripts/priv/screenrecord.sh'
alias user='explorer.exe \\Users\\"$USERNAME"'
alias weather='curl -s wttr.in/M19\ 1RG'

admin () {
	cp -n /git-bash.exe /git-bash-admin.exe
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "$EXEPATH\git-bash-admin.exe" -t REG_SZ -d RUNASADMIN -f 1> /dev/null
	if ! schtasks -run -i -tn "git-bash-admin" &> /dev/null; then
		echo -e "${red}Must launch git-bash via UAC prompt once${reset}"
		explorer "$EXEPATH"\\git-bash-admin.exe
	fi
}

cheat () {
	curl -s cheat.sh/"$1"
}

crop () {
	ffmpegcheck
	inputfile="$(sed 's/'\''//g' <<< "$1")"
	echo -ne "\nTimestamp of where to begin new video [HH:MM:SS] [00:00:00]: "
	read -r begin
	echo -ne "\nTimestamp of where to end new video [HH:MM:SS] [00:00:00]: "
	read -r end
	echo -ne "Name of cropped video: "
	read -r outputfile
	echo -e "${cyan}"

	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/
	ffmpeg -loglevel warning -stats -i "$inputfile" -ss "$begin" -to "$end" -c:v libx264 -vsync 2 -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$outputfile".mp4
	echo -e "\n${yellow}File saved: /c/Users/$USERNAME/Desktop/ScreenRecord/${outputfile}.mp4${reset}"
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

fzycheck () {
	echo -e "${cyan}If you can see this, you have fzy installed" | fzy 2> /dev/null
  if [[ "$?" -eq 127 ]]; then
    echo -e "${yellow}fuzzy not installed${green}"
    currentdir="$PWD"
    mkdir -p /fzytemp && cd /fzytemp
    curl -L --progress-bar "$(curl -s https://packages.msys2.org/package/fzy \
    | grep 'File:' -A1 | grep 'href' | awk '{print $4}' | sed 's/href="//; s/">.*//')" \
    > fzy.pkg.tar.xz
    xz -d fzy.pkg.tar.xz
    tar -xf fzy.pkg.tar -C /
    rm -r /fzytemp
		rm /.BUILDINFO /.MTREE /.PKGINFO
    echo -e "fzy (fuzzy finder) installed${reset}"
		cd "$currentdir"
  fi
}

history () {
	read -r -a select <<< "$(builtin history | tac | fzy -l 25 -p 'Search history: ' | awk '{$1=$2=$3=$4=""; print $0}')"
	if [ -n "$select" ]; then
		builtin history -s 'history'
		builtin history -s "$(echo -E "${select[@]}")"
		echo -ne "${yellow}"
		echo -E "${select[@]}"
		echo -e "\n${cyan}Use 🡡 to edit and/or run this command${reset}"
	fi
}

regedit.exe () {
	schtasks -create -tn "regedit" -sc ONCE -st 01:09 -tr "C:\Windows\regedit.exe" -f -rl HIGHEST &> /dev/null
	if ! schtasks -run -i -tn "regedit" &> /dev/null; then
		echo -e "${red}'regedit' task does not exist\nRun this alias while admin once${reset}"
		explorer "$SYSTEMROOT"\\regedit.exe
		admin
	fi
}

src () {
	source /etc/bash.bashrc
	echo -e "\n${yellow}b${cyan}a${yellow}s${red}h${white}rc ${cyan}s${yellow}o${green}u${red}r${white}c${yellow}e${cyan}d!${reset}"
}

ss () {
	ffmpegcheck
	inputfile="$(sed 's/'\''//g' <<< "$1")"
	echo -ne "\n${green}Video timestamps to be screenshotted [HH:MM:SS] [00:00:00]: "
	read -r -a stamps
	echo -ne "${cyan}"
	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/

	i=1
	for stamp in "${stamps[@]}"; do
	ffmpeg -loglevel quiet -stats -ss "$stamp" -i "$inputfile" -vframes 1 -q:v 1 -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$i".png
	i="$((i+1))"
	done
	echo -ne "$reset"
}

ytaudio () {
	ytcheck
	echo -e "First Paramter - Audio Format: 'flac' or 'best'"
	youtube-dl.exe -x --audio-format $1 $2 $3 $4 $5 $6
}

ytcheck () {
	youtube-dl.exe --version &>/dev/null

	if [[ "$?" -eq 127 ]]; then
		echo -e "\n${yellow}youtube-dl is not installed\n${green}Downloading latest GitHub release..${reset}"
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
