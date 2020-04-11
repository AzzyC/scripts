#!/bin/bash

javarun='java -Xms2G -Xmx5G -jar minecraft_server.jar nogui'

#screen -q

sudo apt update -y
sudo apt install openjdk-8-jdk-headless -y
mkdir ~/minecraft_server
cd ~/minecraft_server
wget -O minecraft_server.jar https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar
$javarun
sed -i 's/false/true/' eula.txt

# Configure Server Properties
sed -i 's/level-name=world/level-name=HawaiiMC/' server.properties
sed -i 's/motd=A Minecraft Server/motd=Grab a tequila on your way in\!/' server.properties
#sed -i 's/ / /' server.properties

$javarun
