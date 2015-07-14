#!/bin/bash

USERNAME=$(whoami)
OLDIFS=$IFS 

INPUT=$(zenity --entry)

updatedb --require-visibility 0 -o ~/.locate.db

IFS='
'
FILEMATCHES=$(locate --database ~/.locate.db -i -b -c $INPUT)
IFS=$OLDIFS 

if [ $FILEMATCHES == 0 ]; then
	zenity --info --text "No matches found" --timeout 2
	exit 1
else
	zenity --info --text "$FILEMATCHES matches found" --timeout 1
fi

IFS='
'
FOUNDFILES=($(locate --database ~/.locate.db -i -b "$INPUT"))
IFS=$OLDIFS 

x=0

while [ $x -lt $FILEMATCHES ]
do
	if [ $x == 0 ]
		then
		echo -n "--list --title FILE-SELECTOR --column serialno. --column file --width 1000 --height 600 --radiolist TRUE \"${FOUNDFILES[$x]}\"" >> /home/$USERNAME/tempzen.txt
		x=$((x+1))
	else
		echo -n " FALSE \"${FOUNDFILES[$x]}\"" >> /home/$USERNAME/tempzen.txt
		x=$((x+1))
	fi
done

set -- $(cat /home/$USERNAME/tempzen.txt)

SELECTEDFILE=$(eval zenity "$@")

if [ $? -eq 0 ] 
then
	zenity --progress --pulsate --timeout 2
fi
IFS='
'
EXTENSION=$(file --mime-type $SELECTEDFILE)

if [ "$SELECTEDFILE" == "" ]
	then
		zenity --info --text "You didn't select any file to open..." --timeout 1
		rm /home/$USERNAME/tempzen.txt
		exit 1
fi

if [ "$SELECTEDFILE" != "" ] && [ "$EXTENSION" == "$SELECTEDFILE: inode/x-empty" ] || [ "$EXTENSION" == "$SELECTEDFILE: text/plain" ] || [ "$EXTENSION" == "$SELECTEDFILE: application/xml" ]
	then
		gedit $SELECTEDFILE
elif [ "$SELECTEDFILE" != "" ] && [ "$EXTENSION" == "$SELECTEDFILE: image/jpg" ] || [ "$EXTENSION" == "$SELECTEDFILE: image/jpeg" ] || [ "$EXTENSION" == "$SELECTEDFILE: image/gif" ] || [ "$EXTENSION" == "$SELECTEDFILE: image/png" ] || [ "$EXTENSION" == "$SELECTEDFILE: image/bmp" ]
	then
		xdg-open $SELECTEDFILE
elif [ "$SELECTEDFILE" != "" ] && [ "$EXTENSION" == "$SELECTEDFILE: text/html" ]
	then
		firefox $SELECTEDFILE
elif [ "$SELECTEDFILE" != "" ] && [ "$EXTENSION" == "$SELECTEDFILE: application/pdf" ]
	then
		gnome-open $SELECTEDFILE
elif [ "$SELECTEDFILE" != "" ] && [ "$EXTENSION" == "$SELECTEDFILE: text/html" ]
	then
		gnome-www-browser $SELECTEDFILE
fi

rm /home/$USERNAME/tempzen.txt
