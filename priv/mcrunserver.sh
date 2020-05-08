#!/bin/bash

extip="$(curl -s ifconfig.me)"

cd ~/minecraft_server

telegram -M "***HawaiiMC*** server is starting..
___Allow 1 minute for server to prepare chunks, before joining! ___
***Server Address***: $extip"

start="$(date +'%-H %-M %-S')"
start=( $start )
starthour="${start[0]}"
startminute="${start[1]}"
startsecond="${start[2]}"

java -Xms2G -Xmx5G -jar forge-1.15.2-31.1.0.jar nogui

end="$(date +'%-H %-M %-S')"
end=( $end )
endhour="${end[0]}"
endminute="${end[1]}"
endsecond="${end[2]}"

if [[ "$((endhour-starthour))" -lt "0" ]]; then
	endhour="$((24+endhour))"
fi

if [[ "$((endminute-startminute))" -lt "0" ]]; then
	endminute="$((60+endminute))"
	endhour="$((endhour-1))"
fi

if [[ "$((endsecond-startsecond))" -lt "0" ]]; then
	endsecond="$((60+endsecond))"
	endminute="$((endminute-1))"
fi

telegram -M "***HawaiiMC*** server is now closed!
***Server Runtime***: ``\`$((endhour-starthour))hour(s) $((endminute-startminute))minute(s) $((endsecond-startsecond))second(s)\```"

cd
