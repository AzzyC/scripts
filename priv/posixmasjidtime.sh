#!/bin/sh
prayertimelist="$(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]*>/ /g; s/Begins//')"

zuhrhour="$(printf '%s' "$prayertimelist" | awk '{print $3}' | cut -d ':' -f1)"
[ "$zuhrhour" -le '12' ] && [ "$zuhrhour" -ge 11 ] && z="$(printf '%s' "$prayertimelist" | awk '{print $3}')" || z="$(date -d "$(printf '%s' "$prayertimelist" | awk '{print $3}') +13 hours" +'%H:%M')"

f="$(printf '%s' "$prayertimelist" | awk '{print $1}')"
s="$(printf '%s' "$prayertimelist" | awk '{print $2}')"
a="$(date -d "$(printf '%s' "$prayertimelist" | awk '{print $4}') +13 hours" +'%H:%M')"
m="$(date -d "$(printf '%s' "$prayertimelist" | awk '{print $5}') +13 hours" +'%H:%M')"
i="$(date -d "$(printf '%s' "$prayertimelist" | awk '{print $6}') +13 hours" +'%H:%M')"

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
  exit 0
}

print_prayertimelist |
for time in "${f}" "${s}" "${z}" "${a}" "${m}" "${i}"; do
  pray="$(date -d "$time" +%s)"
  diff="$(( pray-now ))"
  [ "$pray" -gt "$now" ] && {
    sed "s/${time}/$(printf '\033[1;93m%s' "$time") $(printf '\033[12;94m%02dh:%02dm:%02ds\033[0m' "$(( diff / 3600 ))" "$(( ( diff % 3600 ) / 60 ))" "$(( diff % 60 ))" )/"
    break
  }
done
