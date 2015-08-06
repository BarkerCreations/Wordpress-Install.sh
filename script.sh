#!/usr/bin/env bash
WELCOME="[[[[[-------------------------------]]]]]]\n[[[[[ Wordpress Install Utility 0.1 ]]]]]]\n[[[[[-------------------------------]]]]]]"
NEW_USER_BOOL=""
SHELL_USER_NAME=""
DIRECTORY=""

function userExists {
	if id -u "$1" >/dev/null 2>&1; then
		return 0;
	else
		return 1;
	fi
}

echo $WELCOME

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo" 
   exit 1
fi

#Create a new user to use?
read -e -p "Create a new linux user to own this site? (y/n) " NEW_USER_BOOL
NEW_USER_BOOL=$NEW_USER_BOOL | awk '{print tolower($0)}'

if [ "$NEW_USER_BOOL" = "y" ]; then
	#Y: Name, password?
	read -e -p "What should we call this new user? " SHELL_USER_NAME
	if userExists $SHELL_USER_NAME; then
		echo "nnnoooope"
	else
		echo "okkkaay"
	fi
else if [ "$NEW_USER_BOOL" = "n" ]; then
	#fail state
	echo "Y or N please"
fi

#What directory are we using?

#If not latest wordpress, enter a version number

#Recommended plugins?

#Database name?

#User?

#Password?

#Recommended permissions?