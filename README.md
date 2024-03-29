<h1 align="center">Welcome to AzzyC's Automation repository</h1>
<p>
	<b>Shell scripting averts tediousness of following the same mundane tasks on a machine, where human error is inevitable and will cost time</b>
	<br>
	~ The fact that you can be away from the keyboard, knowing that the scripts will continue to progress is greatly appreciated
	<br>
	~ I am no shell expert; the mentality towards some solutions used in these scripts may not resemble maximum efficiency but it is what I believed was reliable at the time and easy for future manipulation
</p>

<h3>
	<big><b>CLI Screen Recorder</b></big>
	<br>
	═════════════
	<br>
	bash <(curl -Ls <a target="_blank" href="https://github.com/AzzyC/scripts/blob/main/priv/screenrecord.sh">git.io/JtFEh</a>)
</h3>

<p>
	<img align="right" height="495" width="365" src="https://raw.githubusercontent.com/AzzyC/scripts/main/README_images/screenrecord.png">
</p>

<p>
	<b>Prerequisites:</b>
	<br>
	<a target="_blank" href="https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/PortableGit-2.34.1-64-bit.7z.exe">Git for Windows</a>' Bash Terminal
</p>

<p>
	<big><b>Windows Users may want to record their screen to review at a later time; whether it be a class, meeting or an important task</b></big>
	<br>
	<br>
	This script will source programs solely for the screen recording function, and then commence a recording with a <b>default time limit of 2 hours and 15 minutes</b>
	<br>
	&emsp;&emsp;<em>~ Time limit set in case of negligence and to prevent producing a several Gigabyte video</em>
	<br>
	<br>
	Time limit can be manipulated by the User, as shown in the <a target="_blank" href="https://raw.githubusercontent.com/AzzyC/scripts/main/README_images/screenrecord.png">screenshot</a>:
	<br>
	1) Enter <b>number of seconds</b>
	<br>
	&emsp;&emsp;<em>~ Shown in 1st Example</em>
	<br>
	2) Enter time by <b>HH:MM:SS</b> format
	<br>
	&emsp;&emsp;<em>~ Shown in 2nd Example</em>
	<br>
	3) <b>If User wishes to stop recording before a time limit is reached, press 'Ctrl + c'</b>
	<br>
	&emsp;&emsp;<em>~ Shown in 3rd Example</em>
	<br>
	<br>
	`<a target="_blank" href="https://ffmpeg.org/">ffmpeg</a>` is the fundamental component within most recording programs, used for image/video conversions, trimming and streaming and therefore it is used in this script also
	<br>
	<br>
	However, as well as recording the screen, the script uses an audio sniffer library (by default), which captures internal audio as 'hear what you see', meaning you can have your PC on low volume, or even mute, and it will still capture audio at normal volume
	<br>
	&emsp;&emsp;Yet, you may want to capture your Microphone instead of the internal audio, whether it's a Headset or the PC built-in mic.
	<br>
	So, you will type the word 'mic' along with or without a set time limit, which was mentioned above
	<br>
	<br>
	<b>Example scenario (early morning class):
	<br>
	Execute the script, along with a set time limit (optional), see that the recording has started, join class and leave it on screen, put PC sound to mute <em>(if not using 'mic')</em> and proceed with a productive task, such as going back to sleep
	<br>
	Later on, have the ability to skim through the dullness of the class</b>
</p>

<h3>
	<big><b>Google Cloud VNC</b></big>
	<br>
	═════════════
	<br>
	bash <a target="_blank" href="https://github.com/AzzyC/scripts/blob/main/gcloudvnc.sh">scripts/gcloudvnc.sh</a>
</h3>

<p>
	<b>Prerequisites:</b>
	<br>
	<a target="_blank" href="https://www.realvnc.com/en/connect/download/viewer/">VNC Viewer</a>
	<br>
	<a href="https://console.cloud.google.com/compute/instances">Google Cloud Account</a>
</p>

<p>
	All Users have a chance to $300 credits on <a target="_blank" href="https://console.cloud.google.com/compute/instances">Google Cloud Platform</a> where they can loan machine(s) with a range of specs, with a respective cost on the credits, within a year span of the trial
	<br>
	<b>However</b>, the created machines ('cloud instances') can only be accessed via Terminal, which may not be friendly for people who are used to a GUI Environment
	<br><br>
	Therefore, this script will setup a VNC Server on the Google Cloud machine, whereby a GUI Ubuntu (Gnome) Desktop is setup for Users to access with the VNC Viewer
</p>
