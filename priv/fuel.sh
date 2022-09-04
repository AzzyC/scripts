#!/bin/bash

[ -z "$1" ] && {
  blue='\033[0;34m'
  reset='\033[0m'

  printf "%s\n$blue%s$reset\n\n%s\n$blue%s$reset\n" \
  "1st link - Download Odometer Report:" \
  "https://ractelematics.rac.co.uk/Report/Export/CSVExport/?id=21&group=1437-15833&vehicles=32434-32820-100564-100565-113532-113533-113534-121872-152535-152536-152537-153363-184163-188268-188269-188270-195407-208918-209206-211605-230049-230916-231651-235968&reportName=OdometerReport&EndDate=$(date -d 'last-thursday' +'%Y-%m-%d')+23%3a59%3a59&StartDate=$(date -d 'last-thursday 6 days ago' +'%Y-%m-%d')" \
  "2nd link: Quick comparison of Odometer Report values:" \
  "https://ractelematics.rac.co.uk/Report/Run/Report/?id=21&group=1437-15833&vehicles=32434-32820-100564-100565-113532-113533-113534-121872-152535-152536-152537-153363-184163-188268-188269-188270-195407-208918-209206-211605-230049-230916-231651-235968&reportName=OdometerReport&EndDate=$(date -d 'last-thursday' +'%Y-%m-%d')+23%3a59%3a59&StartDate=$(date -d 'last-thursday 6 days ago' +'%Y-%m-%d')"
}

[ -n "$1" ] && {
  newReport="Mileage_$(date +'%m-%d-%y').xls"

  cut -d, -f1,2,8 "$1" | sort -t, -k2 > "$newReport"

  lineNo="$(wc -l < "$newReport")"

  read -ra fuel <<< "$(curl -s "https://www.fleetnews.co.uk/costs/fuel-prices/" | grep 'Premium Diesel PPG' -A 16 | tr -d '\n' | sed 's/<[^>]*>/ /g')"
  fuelCost="$(awk "BEGIN {print (${fuel[4]}+${fuel[5]}) / 2 / 100}")"

  for i in $(seq 3 "$lineNo"); do
    sed -i "${i}s/$/,=(C${i}\/35)*4.54609188*$fuelCost/" "$newReport"
  done

  sed -i \
  -e '2s/$/,Fuel Cost (£)/' \
  -e '3s/$/,,Miles -> Fuel Cost (£) =/' \
  -e "4s/$/,,( Miles \/ MPG (35) ) x 4.54609188 (litres in gallon) x Cost per litre (£$fuelCost)/" \
  -e '6s/$/,,> 1 Car: Grace; Jeff; Mill; Night; Teresa:/' "$newReport"

  grace="$(grep -in 'Grace' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  jeff="$(grep -in 'Jeff' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  mill="$(grep -in 'Mill' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  night="$(grep -in 'Night' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  tere="$(grep -in 'Tere' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  for car in "$grace" "$jeff" "$mill" "$night" "$tere"; do
    sed -i "${car}s/$/,---------->,=SUM(D${car}:D$((car - 1)))/" "$newReport"
  done

  printf '%s' ",TOTAL,=SUM(C3:C${lineNo}),=SUM(D3:D${lineNo})" >> "$newReport"

  explorer "$newReport"
}
