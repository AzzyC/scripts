#!/bin/sh

currentDate=".$(date +'%d%m%y')pray"
tempFile="$HOME/$currentDate"

[ -e "$tempFile" ] || curl -s 'https://shahjalalmosque.org' > "$tempFile"
[ -e "${tempFile}2" ] || grep 'Begins' -A 1 "$tempFile" | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//' > "${tempFile}2"

zuhrhour="$(awk -F ":[0-9]{2}" '{print $3}' "${tempFile}2")"
[ "$zuhrhour" -le '12' ] && [ "$zuhrhour" -ge 11 ] && z="$(awk '{print $3}' "${tempFile}2")" || z="$(date -d "$(awk '{print $3}' "${tempFile}2") +14 hours" +'%H:%M')"

f="$(awk '{print $1}' "${tempFile}2")"
s="$(awk '{print $2}' "${tempFile}2")"
a="$(date -d "$(awk '{print $4}' "${tempFile}2") +14 hours" +'%H:%M')"
m="$(date -d "$(awk '{print $5}' "${tempFile}2") +14 hours" +'%H:%M')"
i="$(date -d "$(awk '{print $6}' "${tempFile}2") +14 hours" +'%H:%M')"

find ~ -maxdepth 1 ! -name "${currentDate}*" -name '*pray*' -exec rm '{}' \;

print_prayertimelist () {
  printf '%s\n' "Prayer Times ($(date +'%d/%m/%Y'))
     Fajr: ${f}
  Sunrise: ${s}
     Zuhr: ${z}
      Asr: ${a}
  Maghrib: ${m}
     Isha: ${i}"
}

now="$(date +%s)"

[ "$now" -ge "$(date -d "${i}" +%s)" ] && {
  print_prayertimelist
  printf '\n\033[1;92m%s\033[0m\n' 'Prayers completed for today, Alhamdulillah!'
} ||
  print_prayertimelist |
  for time in "${f}" "${s}" "${z}" "${a}" "${m}" "${i}"; do
    pray="$(date -d "$time" +%s)"
    [ "$pray" -gt "$now" ] && {
      diff="$(( pray-now ))"
      sed "s/${time}/$(printf '\033[1;93m%s' "$time") $(printf '\033[12;94m%02dh:%02dm:%02ds\033[0m' "$(( diff / 3600 ))" "$(( ( diff % 3600 ) / 60 ))" "$(( diff % 60 ))" )/"
      break
    }
  done
