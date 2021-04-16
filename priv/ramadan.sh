#!/bin/sh
curl -s https://shahjalalmosque.org > ./tempfile
grep 'Begins' -A 1 ./tempfile | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//' > ./tempfile2

f="$(awk '{print $1}' ./tempfile2)"
s="$(awk '{print $2}' ./tempfile2)"
m="$(date -d "$(awk '{print $5}' ./tempfile2) +14 hours" +'%H:%M')"

days="$(grep "$(date +'%d %B')" ./tempfile | awk '{print $7}')"
[ -n "$days" ] && r="$(( days-1 ))"

rm ./tempfile ./tempfile2

print_prayertimelist () {
  printf '%s\n' "Prayer Times ($(date +'%d/%m/%Y'))
     Fajr: ${f}
  Sunrise: ${s}
  Maghrib: ${m}"
}

now="$(date +%s)"

[ "$now" -ge "$(date -d "${m}" +%s)" ] && {
  print_prayertimelist
  printf '\n\033[1;92m%s\033[0m\n' "${r} fasts completed, Alhamdulillah!"
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
  printf '\n\033[1;92m%s\033[0m\n' "$((r-1)) fasts completed, Alhamdulillah!"
}
