#!/bin/sh
start "com.epicgames.launcher://apps/9d2d0eb64d5c44529cece33fe2a46482?action=launch&silent=true"

while ! tasklist -nh -fi "imagename eq GTA5.exe" | grep -q 'GTA5.exe'; do
  printf '\r%s' 'Launching GTA..'
done

printf '\r\033[0;92m%s\033[0m\n\n' 'GTA is running '

taskkill -f -im "Epic*" &&
  printf '\033[0;92m%s\033[0m\n\n' 'EpicGamesLauncher has been killed' ||
  printf '\a\033[0;91m%s\033[0m\n\n' 'EpicGamesLauncher could not be killed'

taskkill -f -im "DSA*" &&
  printf '\033[0;92m%s\033[0m\n\n' 'Intel Driver & Support Assistant has been killed' ||
  printf '\033[0;91m%s\033[0m\n\n' 'Intel Driver & Support Assistant could not be killed'

taskkill -f -im "GameBar*" &&
  printf '\033[0;92m%s\033[0m\n\n' 'Xbox Game Bar has been killed' ||
  printf '\033[0;91m%s\033[0m\n\n' 'Xbox Game Bar could not be killed'

taskkill -f -im "OfficeClickToRun.exe" &&
  printf '\033[0;92m%s\033[0m\n\n' 'Microsoft Office Click-To-Run has been killed' ||
  printf '\033[0;91m%s\033[0m\n\n' 'Microsoft Office Click-To-Run could not be killed'

taskkill -f -im "YourPhone.exe" &&
  printf '\033[0;92m%s\033[0m\n\n' 'YourPhone has been killed' ||
  printf '\033[0;91m%s\033[0m\n\n' 'YourPhone could not be killed'

start "/c/Users/$USERNAME/Documents/modest-menu/antimicro/antimicro.exe" --hidden

sleep 40
start "/c/Users/$USERNAME/Documents/modest-menu/modest-menu.exe"

rm -r '/c/Users/azmat/Documents/Rockstar Games/GTA V/videos/clips'

#schtasks -create -tn "GTAShortKillEpic" -sc ONCE -st 01:09 -tr "$EXEPATH\git-bash-admin.exe -c 'bash <(curl -s https://raw.githubusercontent.com/AzzyC/scripts/main/priv/gtalaunch.sh)'" -f -rl HIGHEST
#create-shortcut --arguments '-run -i -tn GTAShortKillEpic' --description 'GTAV Shortcut' --icon-file '/c/Program Files/Epic Games/GTAV/PlayGTAV.exe' 'schtasks.exe' "/c/Users/$USERNAME/Desktop/GTAV.lnk"
