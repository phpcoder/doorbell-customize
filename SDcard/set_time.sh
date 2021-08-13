#!/bin/sh

##=====================================##
##             _    _   _              ## 
##     ___ ___| |_ | |_(_)_ __  ___    ##
##    (_-</ -_)  _||  _| | '  \/ -_)   ##
##    /__/\___|\__|_\__|_|_|_|_\___|   ##
##               |___|                 ##
##=====================================##

# Sync with local ntp server

	/mnt/disc1/busybox sleep 5

	while true;
	do
		ntpd -q -p 192.168.10.1
		/mnt/disc1/busybox sleep 8
		ntpd -q -p 192.168.10.1
		T=$(date +"%Y-%m-%d %H:%M:%S")
		TZ='EST-5EDT-4,M3.2.0/02:00:00,M11.1.0/02:00:00'
		export TZ
		date -s "$T"
		/mnt/disc1/busybox sleep 21600
		unset TZ
	done
