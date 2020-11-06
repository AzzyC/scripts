curl -s https://shahjalalmosque.org/ | grep Begins -A 1 > masjidtimes.txt # Only scrape lines of HTML where prayer times are
sed -i ' N;s/\n/ /; s/<[^>]\+>/ /g' masjidtimes.txt # Remove HTML tags and merge 2 lines into 1

prayertimelist=( $(cat masjidtimes.txt) ) # Expand into a variable

fajr="${prayertimelist[1]}"
sunrise="${prayertimelist[2]}"
zuhr="${prayertimelist[3]}"
asr="${prayertimelist[4]}"
maghrib="${prayertimelist[5]}"
isha="${prayertimelist[6]}"

printed="$(printf '%s\n' "Prayer Times ($(date +%d/%m/%Y))" "*Fajr*: ${fajr}" "*Sunrise*: ${sunrise}" "*Zuhr*: ${zuhr}" "*Asr*: ${asr}" "*Maghrib*: ${maghrib}" "*Isha*: ${isha}")"
printf '%s\n' "" "$printed" | sed 's/*//g' # No WhatsApp format on Terminal
./telegram "$printed"

rm masjidtimes.txt # Remove temporary file after
