#!/usr/bin/env bash

if ! grep -q bashrc.sh /etc/bash.bashrc; then
	printf '\n%s\n' ". /c/Users/$USERNAME/Documents/scripts/priv/bashrc.sh\
	|| . <(curl -s 'https://raw.githubusercontent.com/AzzyC/scripts/main/priv/bashrc.sh')" \
	>> /etc/bash.bashrc
fi

green="\033[0;92m"
blue="\033[0;94m"
bluebg="\033[44m"
red="\033[0;91m"
redbg="\033[41m"
purple="\033[0;95m"
white="\033[1;97m"
yellow="\033[0;93m"
reset="\033[0m"

PATH="/c/Users/$USERNAME/Documents/PortableGit/platform-tools:/c/Users/$USERNAME/Documents/ffmpeg:$PATH"

HISTFILESIZE='3000'
HISTSIZE='3000'
HISTTIMEFORMAT="[%a %d %T] "
shopt -s histappend

net session >/dev/null 2>&1 && {
	PS1="\[$reset\]\[\033]0;admin: \W\007\]\n ∧ \[$white\]\[$redbg\] \D{%a %d} \[$bluebg\] \t \[$reset\]\n\[$red\][admin@\[$green\]azzy \[$purple\]\w] \[$reset\]➤ "
	cd /
	schtasks -create -tn "git-bash-admin" -sc ONCE -st 01:09 -tr "$EXEPATH\git-bash-admin.exe" -f -rl HIGHEST >&- 2>&-
	reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Open Git-Bash here\command" -d "$EXEPATH\git-bash.exe" -t REG_SZ -f >&-
} ||
	PS1="\[$reset\]\[\033]0;\W\007\]\n ∧ \[$white\]\[$redbg\] \D{%a %d} \[$bluebg\] \t \[$reset\]\n\[$green\][azzy \[$purple\]\w] \[$reset\]➤ "

PS0=" ∨ \[$white\]\[$redbg\] \D{%a %d} \[$bluebg\] \t \[$reset\]\n"
PS2='➤➤ '

alias c="clear"
alias diff="git diff --color=always 2>&1 | sed '/^warning: /d; /^The file/d'"
alias fetch="bash <(curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch)"
alias gitlog="git log --pretty=format:'%h - %an, %ar | %s' | fzy -l 25 -p 'Search commit history: '"
alias nosleep="bash /c/Users/\$USERNAME/Documents/scripts/nosleep.sh"
alias p="/c/Users/\$USERNAME/Documents/scripts/priv/masjidtime.sh || curl -s https://raw.githubusercontent.com/AzzyC/scripts/main/priv/masjidtime.sh | dash"
alias r="bash /c/Users/\$USERNAME/Documents/scripts/priv/screenrecord.sh"
alias ram="dash /c/Users/\$USERNAME/Documents/scripts/priv/ramadan.sh"

admin () {
	cp -n /git-bash.exe /git-bash-admin.exe
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "$EXEPATH\git-bash-admin.exe" -t REG_SZ -d RUNASADMIN -f >&-
	schtasks -run -i -tn "git-bash-admin" >&- 2>&- || {
		printf "${red}%s${reset}" 'Must launch git-bash as admin via UAC prompt once'
		explorer "$EXEPATH"\\git-bash-admin.exe
	}
}

cheat () {
	curl -s cheat.sh/"$1"
}

crop () {
	ffmpegcheck
	inputfile="$1"
	printf '\n%s' 'Timestamp of where to begin new video [HH:MM:SS] [00:00:00]: '
	read -r begin
	printf '\n%s' 'Timestamp of where to end new video [HH:MM:SS] [00:00:00]: '
	read -r end
	printf '\n%s' 'Name of cropped video: '
	read -r outputfile
	printf "${blue}"

	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/
	ffmpeg -loglevel warning -stats -i "$inputfile" -ss "$begin" -to "$end" -c:v libx264 -vsync 2 -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$outputfile".mp4
	printf "\n${yellow}%s${reset}" "File saved: /c/Users/$USERNAME/Desktop/ScreenRecord/${outputfile}.mp4"
	explorer.exe \\Users\\"$USERNAME"\\Desktop\\ScreenRecord\\"$outputfile".mp4
}

ffmpegcheck () {
	ffmpeg -loglevel quiet 2>&-
	[ "$?" -eq 127 ] && {
		printf "\n${yellow}%s\n${green}%s" 'ffmpeg is not installed' 'Downloading latest..'
		curl -L --progress-bar "$(curl -s https://github.com/GyanD/codexffmpeg/releases\
									| grep -m 1 'essentials.*zip'\
									| awk '{print $2}'\
									| sed 's/href="/https:\/\/github.com/; s/"//')"\
									> /c/Users/"$USERNAME"/Documents/temp.zip
		unzip -q /c/Users/"$USERNAME"/Documents/temp.zip -d /c/Users/"$USERNAME"/Documents/ && rm /c/Users/"$USERNAME"/Documents/temp.zip
		mv /c/Users/"$USERNAME"/Documents/ffmpeg-*/bin /c/Users/"$USERNAME"/Documents/ffmpeg && rm -rf /c/Users/"$USERNAME"/Documents/ffmpeg-*/
		reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -v "C:\Users\\${USERNAME}\Documents\ffmpeg\ffmpeg.exe" -t REG_SZ -d HIGHDPIAWARE -f >&-
	}
}

fzycheck () {
	printf "${blue}%s${reset}" 'If you can see this, you have fzy installed' | fzy 2>&-
	[ "$?" -eq 127 ] && {
    printf "${yellow}%s${green}" 'fuzzy not installed'
    currentdir="$PWD"
    mkdir -p /fzytemp && cd /fzytemp
    curl -L --progress-bar "$(curl -s https://packages.msys2.org/package/fzy \
    | grep 'File:' -A1 | grep 'href' | awk '{print $4}' | sed 's/href="//; s/">.*//')" \
    > fzy.pkg.tar.xz
    xz -d fzy.pkg.tar.xz
    tar -xf fzy.pkg.tar -C /
    rm -r /fzytemp
		rm /.BUILDINFO /.MTREE /.PKGINFO
    printf "%s${reset}" "fzy (fuzzy finder) installed"
		cd "$currentdir" || return 1
	}
}

h () {
	history | tac | fzy -l 25 -p 'Search history: ' | awk '{$1=$2=$3=$4=""; print $0}' > ~/history
	[ -s ~/history ] && {
		selected="$(cat ~/history)"
		history -s 'history'
		history -s $selected
		printf "${yellow}%s " $selected
		printf "\n${blue}%s${reset}" 'Use Up arrow to edit and/or run this command'
	}
	rm ~/history
}

src () {
	. /etc/bash.bashrc
	printf "\n${yellow}b${blue}a${yellow}s${red}h${white}r${purple}c ${blue}s${yellow}o${green}u${red}r${white}c${yellow}e${blue}d\e\!${reset}"
}

ss () {
	ffmpegcheck
	inputfile="$1"
	printf "${blue}"
	mkdir -p /c/Users/"$USERNAME"/Desktop/ScreenRecord/

	i=1
	for stamp in "$6" "$5" "$4" "$3" "$2"; do
	ffmpeg -loglevel quiet -stats -ss "$stamp" -i "$inputfile" -vframes 1 -q:v 1 -y /c/Users/"$USERNAME"/Desktop/ScreenRecord/"$i".png
	i="$((i+1))"
	done
	printf "${reset}"
}

weather () {
	curl -s "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/M19" > ./weather
	grep -m 1 "pub" ./weather | sed "s/   *//g; s/<pubDate>/\nLast Updated: /; s/<\/.*/\n/"
	grep -E "(To|title|description|pub)" ./weather \
		| sed "s/Â//g; s/<pub.*//g; s/<[^>]*>//g; s/   *//g; 1,4d; s/Wind D.*Wind/Wind/g; s/Press.*Hum/Hum/g ; s/UV.*Pol/Pol/g; s/Sunrise/\nSunrise/g"
	rm ./weather
}
