#!/bin/bash
# This script is for the neophytes, like me, who carry a slight dislike to working solely in a terminal environment,
# which can occur when using Google Cloud Console, or those wreckless Arch Linux users. Lone terminal use can get
# quite restrictive, and therefore the output of bashing this script, is to allow users to VNC into a
# (GUI Desktop) Environment they may prefer working in due to familiarity. Such benefits include:
# • Uploading files: Though doable, uploading files through terminal can get strenuous. With the new environemt,
# you can simply use the Internet (Firefox) that comes with Ubuntu-Desktop, and upload directly to your Google
# Drive or Mega account.
# • GUI: We've advanced from the terminal age, let us live. File Managers that can be quickly explored through and have
# mutliple instances side-by-side; Visual Feedback is always handy, when you're done editing or cross-running between
# programs. Most importantly, this script is for those of you are still getting familiar with terminal commands, but still
# want a Linux environment.
# • View your VNC instance from any device; viewing the progress of a proccess mobile (e.g. compiling, uploading etc) or 
# to make slight changes that you don't need to be infront of a PC for.
#
# You could coincide this script with './buildrom.sh' if you wish, but it's mainly to provide a User Friendly
# aspect to the Google Cloud Console; making best of the free trial credits, with the blessed specs and Internet
# speeds Google has to offer.
#
sudo apt update && sudo apt upgrade -y
# Update inastance's repository to be able to fetch and install all needed packages in next command.
sudo apt install -y ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal vnc4server
# Setup a GUI Desktop Environment.
sudo ufw allow 5901:5910/tcp
# Setup a Firewall to allow VNC access
vncserver
# Start up a vncserver
#
# User is prompted to enter a Password for the vncserver
#
# Password: *******
# Verify: *******
#
sed -i /^x-terminal-emulator/d ~/.vnc/xstartup
sed -i /^x-window-manager/d ~/.vnc/xstartup
# Remove current environment assets; limited for terminal.
echo -e 'gnome-panel &\ngnome-settings-daemon &\nmetacity &\nnautilus &\ngnome-terminal &' >> ~/.vnc/xstartup
# Include the packages installed above as part of the new environment on VNC startup.
sudo reboot
# Let the changes take effect with a reboot, will disconnect the SSH.
#
# Upon re-opening the SSH Window:
#$ vncserver
# To run the vncserver for the final time.
#
#$ nc 'externalIPAddressOfInstance' 5901
# This is to provide a 'n'ew 'c'onnection for the VNC Server.
# You can find the External IP Address, next to the name you have given to your instance.
#
# You can then use any VNC viewer to view your GUI Enivronment, for example:
# https://www.realvnc.com/en/connect/download/viewer/
# In the 'Enter a VNC Address..' bar, based on the previous terminal command, type:
# 'externalIPAddressOfInstance':5901
#
# Profit!
#
