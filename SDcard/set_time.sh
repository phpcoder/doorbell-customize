#!/bin/sh

##==============================================##
##               __      __  .__                ##
##  ______ _____/  |_  _/  |_|__| _____   ____  ##
## /  ___// __ \   __\ \   __\  |/     \_/ __ \ ##
## \___ \\  ___/|  |    |  | |  |  Y Y  \  ___/ ##
##/____  >\___  >__|____|__| |__|__|_|  /\___  >##
##     \/     \/  /_____/             \/     \/ ##
##==============================================##

##################################################
## NTP Server IP        # Edit your server IP here
TIME_SERVER=192.168.10.1
##################################################
## TimeZone Offset      # Uncomment you timezone
TIMEZONE='EST-5EDT-4,M3.2.0/02:00:00,M11.1.0/02:00:00'     # Eastern
#TIMEZONE='CST-6CDT-5,M3.2.0/02:00:00,M11.1.0/02:00:00'     # Central
#TIMEZONE='MST-7MDT-6,M3.2.0/02:00:00,M11.1.0/02:00:00'     # Mountian
#TIMEZONE='PST-8PDT-7,M3.2.0/02:00:00,M11.1.0/02:00:00'     # Pacific

# Sync with local ntp server

	/mnt/disc1/busybox sleep 5

	while true;
	do
		ntpd -q -p $TIME_SERVER
		/mnt/disc1/busybox sleep 8
		ntpd -q -p $TIME_SERVER
		T=$(date +"%Y-%m-%d %H:%M:%S")
		TZ=$TIMEZONE
		export TZ
		date -s "$T"
		/mnt/disc1/busybox sleep 21600
		unset TZ
	done
