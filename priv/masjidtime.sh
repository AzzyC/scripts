#!/bin/sh

currentDate=".$(date +'%d%m%y')pray"
tempFile="$HOME/$currentDate"

[ -e "$tempFile" ] || curl -s 'https://shahjalalmosque.org' > "$tempFile"
[ -e "${tempFile}2" ] || grep 'Begins' -A 1 "$tempFile" | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//' > "${tempFile}2"

isldate="$(grep "$(date +'%d %B')" "${tempFile}" | awk '{print $7,$8,$9}')"
[ -n "$isldate" ] || rm "${tempFile}" "${tempFile}2"

zuhrhour="$(awk -F ':[0-9]{2}' '{print $3}' "${tempFile}2")"
{ [ "$zuhrhour" -le '12' ] && [ "$zuhrhour" -ge 11 ]; } && z="$(awk '{print $3}' "${tempFile}2")" ||
z="$(( $(awk -F ':[0-9]{2}' '{printf "%d\n", $3}' "${tempFile}2") + 12 )):$(awk -F '[0-9]{2}:' '{sub(/[[:space:]]+$/, "", $4); print $4}' "${tempFile}2") "

f="$(    awk '{print $1}' "${tempFile}2") "
s="$(    awk '{print $2}' "${tempFile}2") "
a="$(( $(awk -F ':[0-9]{2}' '{printf "%d\n", $4}' "${tempFile}2") + 12 )):$(awk -F '[0-9]{2}:' '{sub(/[[:space:]]+$/, "", $5); print $5}' "${tempFile}2") "
m="$(( $(awk -F ':[0-9]{2}' '{printf "%d\n", $5}' "${tempFile}2") + 12 )):$(awk -F '[0-9]{2}:' '{sub(/[[:space:]]+$/, "", $6); print $6}' "${tempFile}2") "
i="$(( $(awk -F ':[0-9]{2}' '{printf "%d\n", $6}' "${tempFile}2") + 12 )):$(awk -F '[0-9]{2}:' '{sub(/[[:space:]]+$/, "", $7); print $7}' "${tempFile}2") "

find ~ -maxdepth 1 ! -name "${currentDate}*" -name '*pray*' -exec rm '{}' \;

print_prayertimelist () {
  printf '%s\n' "Prayer Times: $(date +'%d/%m/%Y') | $isldate
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
      sed "s/${time}/$(printf '\033[1;93m%s' "$time")$(printf '\033[12;94m%02dh:%02dm:%02ds\033[0m' "$(( diff / 3600 ))" "$(( ( diff % 3600 ) / 60 ))" "$(( diff % 60 ))" )/"
      break
    }
  done
