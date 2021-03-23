#!/usr/bin/env bash
read -r -a prayertimelist <<< "$(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]\+>/ /g; s/Begins//')"

[ "$(cut -d ':' -f1 <<< "${prayertimelist[2]}")" -le '12' ] && zuhr="${prayertimelist[2]}" || zuhr="$(date -d "${prayertimelist[2]} +13 hours" +'%H:%M')"

hrprayertimelist=( "${prayertimelist[0]}"
"${prayertimelist[1]}"
"${zuhr}"
"$(date -d "${prayertimelist[3]} +13 hours" +'%H:%M')"
"$(date -d "${prayertimelist[4]} +13 hours" +'%H:%M')"
"$(date -d "${prayertimelist[5]} +13 hours" +'%H:%M')"
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
  exit 0
}

print_prayertimelist |
for time in "${hrprayertimelist[@]}"; do
  pray="$(date -d "$time" +%s)"
  diff="$(( pray-now ))"
  [ "$pray" -gt "$now" ] && {
    sed "s/${time}/$(printf '\033[1;93m%s' "$time") $(printf '\033[12;94m%02dh:%02dm:%02ds\033[0m' "$(( diff / 3600 ))" "$(( ( diff % 3600 ) / 60 ))" "$(( diff % 60 ))" )/"
    break
  }
done
