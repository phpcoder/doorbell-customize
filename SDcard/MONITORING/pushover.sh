#!/bin/sh

#================================================================#
## __________             .__     ________                      ##
## \______   \__ __  _____|  |__  \_____  \___  __ ___________  ##
##  |     ___/  |  \/  ___/  |  \  /   |   \  \/ // __ \_  __ \ ##
##  |    |   |  |  /\___ \|   Y  \/    |    \   /\  ___/|  | \/ ##
##  |____|   |____//____  >___|  /\_______  /\_/  \___  >__|    ##
##                      \/     \/         \/          \/        ##
#================================================================#

## Script Name: send_pic_pushover.sh
## Decription: Sends a PushOver notifaction with an image
##             attachment. Alarm with taking snapshot 
##             should be enabled in the doorbell.

##################################################################
## User Key        					# Edit your User Key here.
#================================================================#
USER_KEY="ueveujttxfakeuserkeyieg7777"
#==================================================

##################################################################
## APP Token      					# Edit your App Token here.
#================================================================#
APP_TOKEN="ak9gb9hdqfakeapptokena3oy7777"
#================================================================#

#Send PushOver notifaction

# Today's date - such dir should be created for alarm pics
DIR=`date +%Y-%m-%d`

# Alarm picture storage
PTH="/mnt/disc1/npc/push/alarm"

# Wait until snapshot is taken
#/mnt/disc1/busybox sleep 5

# Find latest image in the current date folder
LATEST=`ls -t ${PTH}/${DIR} | /mnt/disc1/busybox head -1`

# Full filename with path
FILE=${PTH}/${DIR}/${LATEST}

# Timestamp of the file creation date
TS=`/mnt/disc1/busybox stat -c %Y ${FILE}`

# File creation date in readable format
FDATE=`date -d @${TS} +'%Y-%m-%d %H:%M:%S'`

# Send latest image
/mnt/disc1/MONITORING/curl -s \
  --form-string "token=${APP_TOKEN}" \
  --form-string "user=${USER_KEY}" \
  --form-string "message=Doorbell ring !!! ${LATEST} - Created at ${FDATE}" \
  -F "attachment=@${FILE}" \
  http://api.pushover.net/1/messages.json >/dev/null 2>&1
  
   
exit 0
