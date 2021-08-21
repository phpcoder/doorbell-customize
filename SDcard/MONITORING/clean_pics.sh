#!/bin/sh

#==================================================
## Script Name:	clean_pics.sh
## Decription: 	Deletes directory containing 
##				      the previous days images.
## Instructions:	Run as cron job 55 23 * * *
#==================================================

# Yesterdays date - such dir should be created for alarm pics
DIR=`date -d "-13:00" '+%Y-%m-%d'`

# Alarm picture storage
PTH="/mnt/disc1/npc/push/alarm"
 
	if [ -d "${PTH}/${DIR})" ]; then
		rm -r "${PTH}/${DIR}"
	else
		echo "${PTH} is empty"
	fi
	
exit 0
