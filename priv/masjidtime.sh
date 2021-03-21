#!/bin/bash
read -r -a prayertimelist <<< "$(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]\+>/ /g; s/Begins//')"

if [ "$(cut -d ':' -f1 <<< "${prayertimelist[2]}")" -le '12' ]; then
  zuhr="${prayertimelist[2]}"
else
  zuhr="$(date +'%H:%M' -d "${prayertimelist[2]} +13 hours")"
fi

hrprayertimelist=( "${prayertimelist[0]}"
"${prayertimelist[1]}"
"${zuhr}"
"$(date -d "${prayertimelist[3]} +13 hours" +'%H:%M')"
"$(date -d "${prayertimelist[4]} +13 hours" +'%H:%M')"
"$(date -d "${prayertimelist[5]} +13 hours" +'%H:%M')"
)

echo "Prayer Times ($(date +'%d/%m/%Y'))
Fajr: ${hrprayertimelist[0]}
Sunrise: ${hrprayertimelist[1]}
Zuhr: ${hrprayertimelist[2]}
Asr: ${hrprayertimelist[3]}
Maghrib: ${hrprayertimelist[4]}
Isha: ${hrprayertimelist[5]}" | {
  now="$(date +%s)"

  for time in "${hrprayertimelist[@]}"; do
    [ "$now" -lt "$(date -d "$time" +%s)" ] && GREP_COLOR='1;93' grep -z --color "${time}" && break
  done
}
