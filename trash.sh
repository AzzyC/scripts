echo ""
if [ -d ~/.local/share/Trash/files ]
then
	echo "Current files & size of Recycle Bin:"
	ls -AhsXx --color=always ~/.local/share/Trash/files
# -A = Show 'dot' files
# -h = Human Readable File/Directories sizes
# -s = Show File/Directories sizes
# -X = Sort alphabetically
# -x = Show File/Directories in a line; not columns
# --color = Show colour to differentiate between Files and Directories
	echo ""
	while ! [[ $REPLY =~ ^(Y|y|N|n)$ ]]
	do
	read -p "trash.sh: Would you like to permanently remove all Files/Directories in Recycle Bin (y/N) " -n 2 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo ""
		sudo rm -rfv ~/.local/share/Trash/
		echo ""
	elif [[ $REPLY =~ ^[Nn]$ ]] 
	then
		echo ""
		echo "Spotted something you need ay? ;]"
		echo ""
		echo "No action taken"
		echo ""
	fi
	done
else
	echo "You currently do not have a Recycle Bin; Remove (a) File(s) or Directory(ies)"
	echo ""
fi
unset REPLY
