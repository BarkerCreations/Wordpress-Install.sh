#!/bin/bash
WELCOME1="[[[[[-------------------------------]]]]]]"
WELCOME2="[[[[[ Wordpress Install Utility 0.1 ]]]]]]"
WELCOME3="[[[[[-------------------------------]]]]]]"
SHELL_USER_NAME=""
DIRECTORY=""
DB_NAME=""
DB_USER=""
DB_PW=""
DB_R_PW=""

#regex define[\s\S]+DB_NAME[\s\S]+utf8[\s\S]+\)\S

ERROR_COLOR="\[\033[1;31m\]"
REG_COLOR="\[\033[0m\]"
GREEN_COLOR='\[\033[0;32m\]'

BOLD_TEXT=$(tput bold)
NORMAL_TEXT=$(tput sgr0)

userExists () {
	if id -u "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

echoError () {
	echo "**${1}**"
}

echoFeedback () {
	echo "--${1}--"
}

checkUsername () {
	#Create a new user to use?
	read  -p "${BOLD_TEXT}What user should own this install (other than www-data)?${NORMAL_TEXT} " SHELL_USER_NAME
	SHELL_USER_NAME=$SHELL_USER_NAME | awk '{print tolower($0)}'

	if userExists $SHELL_USER_NAME; then
		echoFeedback "Chose existing user"
		return 1
	else

		echoError "This is a new user, currently not supported"
		checkUsername
	fi
}

checkDir () {
	read  -p "${BOLD_TEXT}Where should we install wp?${NORMAL_TEXT} " DIRECTORY
	if [ ! -d $DIRECTORY ] ; then
		# try again
		echoError "That isn't a directory that exists right now"
		checkDir
	fi
}

getDBDetails () {
	read  -p "${BOLD_TEXT}Please enter a new db name${NORMAL_TEXT} " DB_NAME
	read  -p "${BOLD_TEXT}Please enter a new db user${NORMAL_TEXT} " DB_USER
	read -s -p "${BOLD_TEXT}What password should that user have?${NORMAL_TEXT} " DB_PW
	echo "\n" 
	read -s -p "${BOLD_TEXT}Finally, what is the root mysql password?${NORMAL_TEXT} " DB_R_PW
	echo "\n" 

	mysql --user="root" --password="${DB_R_PW}" -execute="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PW}'; CREATE DATABASE ${DB_NAME}; GRANT ALL PRIVILEGES ON ${DB_NAME} TO '${DB_USER}'@'localhost';"
}

editWPConfig () {
	echoFeedback "Paste the following into your wp-config.php file: "
	echo
	echo "define( 'DB_NAME',     '${DB_NAME}' );"
	echo "define( 'DB_USER',     '${DB_USER}' );"
	echo "define( 'DB_PASSWORD', '${DB_PW}' );"
	echo "define( 'DB_HOST',     'localhost' );"
	echo "define( 'DB_CHARSET',  'utf8' );"
	echo
}

download () {
	echoFeedback "Downloading wp latest"
    local url="https://wordpress.org/latest.tar.gz"
    curl -o "${DIRECTORY}/wp.tar.gz" $url
    tar -xzf wp.tar.gz
    sudo mv wordpress/* ./
    sudo rm -R wordpress
    sudo cp ./wp-config-sample.php ./wp-config.php

    #permissions and ownership
    find . -type d -print0 | xargs -0 sudo chmod 0775 # For directories
	find . -type f -print0 | xargs -0 sudo chmod 0664 # For files
	NEW_GROUP=${SHELL_USER_NAME}_${DB_NAME}_WP
	sudo groupadd $NEW_GROUP
	usermod -a -G $NEW_GROUP $SHELL_USER_NAME
	usermod -a -G $NEW_GROUP www-data
	sudo chown -R $NEW_GROUP .

    echoFeedback "Downloaded and extracted with permissions"
}

echo ${BOLD_TEXT}${WELCOME1}${NORMAL_TEXT}
echo ${BOLD_TEXT}${WELCOME2}${NORMAL_TEXT}
echo ${BOLD_TEXT}${WELCOME3}${NORMAL_TEXT}

if [[ $EUID -ne 0 ]]; then
   echoError "This script must be run as root or with sudo" 
   exit 1
fi

#What user owns themes etc?
checkUsername

#What directory are we using?
checkDir

#Get wp latest
download

#Database name?
MYSQL=`which mysql`

if [ ! -f "$MYSQL" ]; then
	echoError "No mysql detected"
	exit 1
fi

getDBDetails

editWPConfig
