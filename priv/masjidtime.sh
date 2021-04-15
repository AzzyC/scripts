#!/bin/sh
curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//' > ./tempfile

zuhrhour="$(awk -F ":[0-9]{2}" '{print $3}' ./tempfile)"
[ "$zuhrhour" -le '12' ] && [ "$zuhrhour" -ge 11 ] && z="$(awk '{print $3}' ./tempfile)" || z="$(date -d "$(awk '{print $3}' ./tempfile) +14 hours" +'%H:%M')"

f="$(awk '{print $1}' ./tempfile)"
s="$(awk '{print $2}' ./tempfile)"
a="$(date -d "$(awk '{print $4}' ./tempfile) +14 hours" +'%H:%M')"
m="$(date -d "$(awk '{print $5}' ./tempfile) +14 hours" +'%H:%M')"
i="$(date -d "$(awk '{print $6}' ./tempfile) +14 hours" +'%H:%M')"

rm ./tempfile

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
