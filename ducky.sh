#!/bin/bash

# setup the default values that is needed
defaultKeyboard="us"
defaultDuckSpark=""

echo
echo "========================================="
echo "Bash script to generate and flash"
echo "digispark device to act as a ducky"
echo "By Martin Skytte"
echo "========================================="
echo 

getMenu() {
	while :
	do
		echo "Choose what to do, followed by [ENTER]:"
		echo "Generate full script [1]"
		echo "Exit script [0]"
	
		read menuItem
	
		case ${menuItem} in
			0) echo "Bye!"; exit;;
			1) getOs; getDuckyFile; generateDucky; duckySpark; echo "Script executed! Have fun DUCKING!"; exit;;
			*) ERR_MSG="Please enter a valid option!"
		esac
	
		clear
	done
}

# find which os that is
# currently being used
getOs() {
	unameOut="$(uname -s)"
	case "${unameOut}" in
		Linux*)     machine=Linux;;
		Darwin*)    machine=Mac;;
		CYGWIN*)    machine=Cygwin;;
		MINGW*)     machine=MinGw;;
		*)          machine="UNKNOWN:${unameOut}"
	esac

	echo "Running on: ${machine}"
	echo 
}

# Get the ducky file
# that needs to be converted
# into a ducky bin file
getDuckyFile() {
	echo "Enter the ducky script that needs to be converted, followed by [ENTER]:"

	while read file && [ ! -f "${file}" ]
	do
		echo "File: ${file} does not exists!"
		echo 
		echo "Enter the ducky script that needs to be converted, followed by [ENTER]:"
	done

	filename="$(basename "${file}")"

	echo 
	echo "filename: ${filename}"
	echo

	extension="${filename##*.}"
	filename="${filename%.*}"
}

# Convert from file into a ducky bin
# that can be used for generating the
# ino file for the spark board
generateDucky() {	
	echo "Enter keyboard layout (default ${defaultKeyboard}), followed by [ENTER]"
	echo

	read keyboard

	if [ ! -n "${keyboard}" ] 
	then
		keyboard="${defaultKeyboard}"
	fi

	echo "Encoding ducky script with keyboard layout ${keyboard}..."
	echo

	mkdir -p "Payloads/${filename}"

	java -jar USB-Rubber-Ducky/Encoder/encoder.jar -i "${file}" -o "Payloads/${filename}/${filename}.bin" -l ${keyboard}
}

# Convert the file to a ino file
duckySpark() {

	echo "Add extra parameters to the duck2spark (default "${defaultDuckSpark}"), example \"-l 4 -f 2500 -r 3000\", followed by [ENTER]"

	read extraParams

	if [ ! -n "${extraParams}" ] 
	then
		extraParams="${defaultDuckSpark}"
	fi

	echo "Generating ino file for the spark board"

	python duck2spark/duck2spark.py -i "Payloads/${filename}/${filename}.bin" -o "Payloads/${filename}/${filename}.ino" ${extraParams}
}

flashToBoard() {
	if [ ${machine} != "Mac" ]
	then
		arduino --board digistump:avr:digispark-tiny  --upload 
	else
		echo
		echo "it's a Mac"
	fi
}

getMenu