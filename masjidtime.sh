prayertimelist=( $(curl -s https://shahjalalmosque.org/ | grep Begins -A 1 | sed 'N;s/\n/ /; s/<[^>]\+>/ /g') )
# Expanded variable: grep: Only scrape HTML containing prayer times; sed: Merge multiple lines into 1 and remove HTML tags

fajr="${prayertimelist[1]}"
sunrise="${prayertimelist[2]}"
zuhr="${prayertimelist[3]}"
asr="${prayertimelist[4]}"
maghrib="${prayertimelist[5]}"
isha="${prayertimelist[6]}"

printed="$(printf '%s\n' "Prayer Times ($(date +%d/%m/%Y))" "*Fajr*: ${fajr}" "*Sunrise*: ${sunrise}" "*Zuhr*: ${zuhr}" "*Asr*: ${asr}" "*Maghrib*: ${maghrib}" "*Isha*: ${isha}")"
printf '%s\n' "" "$printed" | sed 's/*//g' # No WhatsApp format on Terminal
./telegram "$printed"
