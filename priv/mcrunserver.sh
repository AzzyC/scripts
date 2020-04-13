#!/bin/bash

cd ~/minecraft_server

echo "Server opened at $(date -d '+1 hour' '+%d-%m-%y_%H:%M:%S')" 2>&1 | tee -a ~/timeelapsed.txt
java -Xms2G -Xmx5G -jar forge-1.15.2-31.1.0.jar nogui
echo "Server closed at $(date -d '+1 hour' '+%d-%m-%y_%H:%M:%S')" 2>&1 | tee -a ~/timeelapsed.txt

cd
