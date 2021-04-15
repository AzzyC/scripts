#!/usr/bin/env bash
read -r -a prayertimelist <<< "$(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//')"

zuhrhour="$(cut -d ':' -f1 <<< "${prayertimelist[2]}")"
[ "$zuhrhour" -le '12' ] && [ "$zuhrhour" -ge 11 ] && zuhr="${prayertimelist[2]}" || zuhr="$(date -d "${prayertimelist[2]} +14 hours" +'%H:%M')"

hrprayertimelist=( "${prayertimelist[0]}"
"${prayertimelist[1]}"
"${zuhr}"
"$(date -d "${prayertimelist[3]} +14 hours" +'%H:%M')"
"$(date -d "${prayertimelist[4]} +14 hours" +'%H:%M')"
"$(date -d "${prayertimelist[5]} +14 hours" +'%H:%M')"
)

print_prayertimelist () {
  printf '%s\n' "Prayer Times ($(date +'%d/%m/%Y'))
  Fajr: ${hrprayertimelist[0]}
  Sunrise: ${hrprayertimelist[1]}
  Zuhr: ${hrprayertimelist[2]}
  Asr: ${hrprayertimelist[3]}
  Maghrib: ${hrprayertimelist[4]}
  Isha: ${hrprayertimelist[5]}"
}

now="$(date +%s)"

[ "$now" -ge "$(date -d "${hrprayertimelist[5]}" +%s)" ] && {
  print_prayertimelist
  printf '\n\033[1;92m%s\033[0m\n' 'Prayers completed for today, Alhamdulillah!'
} ||
  print_prayertimelist |
  for time in "${hrprayertimelist[@]}"; do
    pray="$(date -d "$time" +%s)"
    [ "$pray" -gt "$now" ] && {
      diff="$(( pray-now ))"
      sed "s/${time}/$(printf '\033[1;93m%s' "$time") $(printf '\033[12;94m%02dh:%02dm:%02ds\033[0m' "$(( diff / 3600 ))" "$(( ( diff % 3600 ) / 60 ))" "$(( diff % 60 ))" )/"
      break
    }
  done
