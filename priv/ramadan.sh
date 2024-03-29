#!/bin/sh

while true; do

  currentDate=".$(date +'%d%m%y')pray"
  tempFile="$HOME/$currentDate"

  find ~ -maxdepth 1 ! -name "${currentDate}*" -name '*pray*' -exec rm '{}' \;

  [ -e "$tempFile" ] || curl -s 'https://shahjalalmosque.org' > "$tempFile"
  [ -e "${tempFile}2" ] || grep 'Begins' -A 1 "$tempFile" | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//' > "${tempFile}2"

  f="$(awk '{print $1}' "${tempFile}2")"
  s="$(awk '{print $2}' "${tempFile}2")"
  m="$(( $(awk -F ':[0-9]{2}' '{printf "%d\n", $5}' "${tempFile}2") + 12 )):$(awk -F '[0-9]{2}:' '{sub(/[[:space:]]+$/, "", $6); print $6}' "${tempFile}2")"

  isldate="$(grep "$(date +'%d %B')" "${tempFile}" | awk '{print $7,$8,$9}')"
  days="$(printf '%s' "$isldate" | awk '{print $1}')"
  [ -n "$days" ] || rm "${tempFile}" "${tempFile}2"

  print_prayertimelist () {
    printf '%s\n' "" "Prayer Times: $(date +'%d/%m/%Y') | $isldate
        Fajr: ${f}
     Sunrise: ${s}
     Maghrib: ${m}"
  }

  now="$(date +%s)"

  clear
  [ "$now" -ge "$(date -d "${m}" +%s)" ] && {
    print_prayertimelist
    printf '\n\033[1;92m%s\033[0m\n' "$days fasts completed, Alhamdulillah!"
  } || {
    print_prayertimelist |
    for time in "${f}" "${m}"; do
      pray="$(date -d "$time" +%s)"
      [ "$pray" -gt "$now" ] && {
        diff="$(( pray-now ))"
        sed "s/${time}/$(printf '\033[1;93m%s' "$time") $(printf '\033[12;94m%02dh:%02dm:%02ds\033[0m' "$(( diff / 3600 ))" "$(( ( diff % 3600 ) / 60 ))" "$(( diff % 60 ))" )/"
        break
      }
    done
    printf '\n\033[1;92m%s\033[0m\n' "$((days - 1)) fasts completed, Alhamdulillah!"
  }

  [ "$1" = loop ] || exit 0

  [ -f ~/alarm.mp3 ] || curl -o ~/alarm.mp3 https://cdn.pixabay.com/download/audio/2022/06/12/audio_eb85589880.mp3?filename=oversimplified-alarm-clock-113180.mp3

  { [ "$now" -ge "$(date -d "${m}" +%s)" ] && [ "$now" -le "$(date -d "${m} + 1 minute" +%s)" ]; } && {
    play -q ~/alarm.mp3 2>&- || pkg install sox 2>&-
  }

  { [ "$now" -ge "$(date -d "${f} 16 minutes ago" +%s)" ] && [ "$now" -le "$(date -d "${f} 15 minutes ago" +%s)" ]; } && {
    play -q ~/alarm.mp3 2>&- || pkg install sox 2>&-
  }

done
