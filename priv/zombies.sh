#!/bin/sh
"/c/Users/$USERNAME/Documents/My Games/Black Ops 2/plutonium.exe"

printf '\r\033[0;92m%s\033[0m\n\n' 'Plutonium is running '

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

sleep 10

#create-shortcut --arguments '-c "dash /c/Users/$USERNAME/Documents/scripts/priv/zombies.sh"' --description 'Run Plutonium and end background processes' --icon-file "/c/Users/$USERNAME/Documents/My Games/Black Ops 2/plutonium.exe" '/git-bash.exe' "/c/Users/$USERNAME/Desktop/plutonium.lnk"
