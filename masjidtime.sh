prayertimelist=( $(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]\+>/ /g') )

fajr="${prayertimelist[1]}"
sunrise="${prayertimelist[2]}"
zuhr="${prayertimelist[3]}"
asr="${prayertimelist[4]}"
maghrib="${prayertimelist[5]}"
isha="${prayertimelist[6]}"

printf '%s\n' "Prayer Times ($(date +%d/%m/%Y))" "Fajr: ${fajr}" "Sunrise: ${sunrise}" "Zuhr: ${zuhr}" "Asr: ${asr}" "Maghrib: ${maghrib}" "Isha: ${isha}"
