#!/bin/sh

[ -z "$1" ] && {
  blue='\033[0;34m'
  reset='\033[0m'

  printf "%s\n$blue%s$reset\n\n%s\n$blue%s$reset\n" \
  "1st link - Download Odometer Report:" \
  "https://ractelematics.rac.co.uk/Report/Export/CSVExport/?id=21&group=1437-15833&vehicles=32434-32820-100564-100565-113533-121872-144559-152535-152536-152537-153363-188268-188269-188270-195407-208918-209206-211605-230049-230916-231651-235968-247526-253321-255381&&reportName=OdometerReport&EndDate=$(date -d 'last-sunday' +'%Y-%m-%d')+23%3a59%3a59&StartDate=$(date -d 'last-sunday 6 days ago' +'%Y-%m-%d')" \
  "2nd link - Quick comparison of Odometer Report values:" \
  "https://ractelematics.rac.co.uk/Report/Run/Report/?id=21&group=1437-15833&vehicles=32434-32820-100564-100565-113533-121872-144559-152535-152536-152537-153363-188268-188269-188270-195407-208918-209206-211605-230049-230916-231651-235968-247526-253321-255381&&reportName=OdometerReport&EndDate=$(date -d 'last-sunday' +'%Y-%m-%d')+23%3a59%3a59&StartDate=$(date -d 'last-sunday 6 days ago' +'%Y-%m-%d')"
}

[ -n "$1" ] && {
  newReport="Mileage_$(date +'%m-%d-%y').xls"

  cut -d, -f1,2,8 "$1" | sort -t, -k2 > "$newReport"

  lineNo="$(wc -l < "$newReport")"

  fuel="$(curl -s "https://www.confused.com/petrol-prices/fuel-price-index" | grep -E 'price--petrol"|price--diesel"' | sed 's/<[^>]*>/ /g; s/p//')"
  petrol="$(printf '%s' "$fuel" | head -n 1)"
  diesel="$(printf '%s' "$fuel" | tail -n 1)"
  fuelCost="$(awk "BEGIN {print (${petrol}+${diesel}) / 1.9 / 100}")"

  printf '%s\n' \
  "Avg. Petrol Cost:   $(awk "BEGIN {print ${petrol} / 100}")" \
  "Avg. Diesel Cost:   $(awk "BEGIN {print ${diesel} / 100}")" \
  "                   -------" \
  "Chosen Fuel Cost:  $fuelCost"

  for i in $(seq 3 "$lineNo"); do
    sed -i "${i}s/$/,=(C${i}\/35)*4.54609188*$fuelCost/" "$newReport"
  done

  sed -i \
  -e '2s/$/,Fuel Cost (£),,Miles -> Fuel Cost (£) =/' \
  -e "3s/$/,,( Miles \/ MPG (35) ) x 4.54609188 (litres in gallon) x Cost per litre (£$fuelCost)/" \
  -e '4s/$/,,> 1 Car: Carla; Grace; Jeff; Lawrence; Mill; Night; Teresa:/' "$newReport"

  carla="$(grep -in 'Carla' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  derw="$(grep -in 'Derw' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  grace="$(grep -in 'Grace' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  jeff="$(grep -in 'Jeff' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  night="$(grep -in 'Night' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  spring="$(grep -in 'Spring' "$newReport" | tail -n1 | awk -F ':' '{print $1}')"
  for car in "$carla" "$derw" "$grace" "$jeff" "$night" "$spring"; do
    sed -i "${car}s/$/,---------->,=SUM(D${car}:D$((car - 1)))/" "$newReport"
  done

  printf '%s' ",TOTAL,=SUM(C3:C${lineNo}),=SUM(D3:D${lineNo})" >> "$newReport"

  explorer "$newReport"
}
