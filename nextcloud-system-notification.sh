#!/bin/bash

# By Georgiy Sitnikov.
#
# AS-IS without any warranty.
# Original tread https://help.nextcloud.com/t/howto-get-notifications-for-system-updates/10299 

# Adjust to your NC installation
	# Administrator User to notify
USER="admin"
	# Your NC OCC Command path
COMMAND=/var/www/nextcloud/occ
	# Your PHP location
PHP=/usr/bin/php

################

# Check if OCC is reacheble
if [ ! -w "$COMMAND" ]; then
	echo "ERROR - Command $COMMAND not found. Make sure taht path is corrct."
	exit 1
else
	if [ "$EUID" -ne "$(stat -c %u $COMMAND)" ]; then
		echo "ERROR - Command $COMMAND not executable for current user.
	Make sure that user has right to execute it.
	Script must be executed as $(stat -c %U $COMMAND)."
		exit 1
	fi
fi

# Check if php is executable
if [ ! -x "$PHP" ]; then
	echo "ERROR - PHP not found, or not executable."
	exit 1
fi

#PACKAGES=$(apt list --upgradable 2>&1)
PACKAGESRAW=$(apt-get -s dist-upgrade | awk '/^Inst/ { print $2 }' 2>&1)
NUM_PACKAGES=$(echo "$PACKAGESRAW" | wc -l)
PACKAGES=$(echo "$PACKAGESRAW"|xargs)

if [ "$PACKAGES" != "" ]; then

	UPDATE_MESSAGE=$(echo "Packages to update: $PACKAGES" | sed -r ':a;N;$!ba;s/\n/, /g')
	$PHP $COMMAND notification:generate $USER "$NUM_PACKAGES packages require to be updated" -l "$UPDATE_MESSAGE"
#	echo $NUM_PACKAGES $UPDATE_MESSAGE

elif [ -f /var/run/reboot-required ]; then

	$PHP $COMMAND notification:generate $USER "System requires a reboot"

fi

exit 0
