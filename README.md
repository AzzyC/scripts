$ git clone https://github.com/AzzyC/scripts.git --depth=1

$ sudo chmod +x scripts/* scripts/&ast;/&ast;

#############################################

Public: 'android9.sh'

$ . scripts/android9.sh

Minimalistic approach to build ROM's. No unnecessary commands or other functions, just set out to build Lineage-16.0 for starxxx.

Note: If building on an OS higher than Ubuntu 16.04, the script will change default Java Version to Java 8, or 'openjdk-8', as this is needed to compile ⩾ Android 5.0. - If you ever need to switch back to a new(er) Java version, use this command to see installed Java Versions:

$ sudo update-alternatives --config java

#############################################

Private: 'android9.sh'

$ . scripts/priv/android9.sh

Similar to public; includes commands to upload files via terminal without a GUI environment.

#############################################

'gcloudvnc.sh'

$ . scripts/gcloudvnc.sh

Some Users can be financially disadvantaged to being able operate the best spec hardware, with a decent amount of RAM or core performance for tasks like video rendering, ROM compiling, etc. as it takes a substantial toll on a machine. Fortunately, all Users have a chance at a $300 Trial for Google Cloud Platform where they can loan a machine to their desired specs for as long their Free Trial remains, which after of course Users should be entitled to pay. The machine can be accessed only via an SSH Terminal which not every user may be comfortable with and would rather prefer to work in a GUI Environment instead.

That is where this script takes a role. Bashing this script will setup a VNC Server for a Google Cloud machine, whereby it can be connected out with a GUI Ubuntu (Gnome) Desktop that Users can access with an VNC Viewer, such as https://www.realvnc.com/en/connect/download/viewer/
Be sure to read the notes inside the script for further details on how to utilise this script.

#############################################
