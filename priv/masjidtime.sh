read -r -a prayertimelist <<< "$(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]\+>/ /g; s/Begins//')"

echo "Prayer Times ($(date +'%d/%m/%Y'))
Fajr: ${prayertimelist[0]}
Sunrise: ${prayertimelist[1]}
Zuhr: ${prayertimelist[2]}
Asr: ${prayertimelist[3]}
Maghrib: ${prayertimelist[4]}
Isha: ${prayertimelist[5]}"
