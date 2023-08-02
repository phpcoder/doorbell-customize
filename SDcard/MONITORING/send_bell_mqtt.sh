#!/bin/sh

###############################################
##   __  __  ___ _____ _____ ___ _   _ ___   ##
##  |  \/  |/ _ \_   _|_   _| _ \ | | | _ )  ##
##  | |\/| | (_) || |   | | |  _/ |_| | _ \  ##
##  |_|  |_|\__\_\|_|   |_|_|_|  \___/|___/  ##
##                       |___|               ##
##                                           ##
###############################################


#Publish MQTT
# Sends an Image over MQTT on button press of the SD-M5 Doorbell.
# Edit fields for Username and Password and change local IP address & port to point at your MQTT Broker

# Today's date - such dir is created for alarm pics
DIR=`date +%Y-%m-%d`

# Alarm picture storage
PTH="/mnt/disc1/npc/push/alarm"

# Wait until snapshot is taken
/mnt/disc1/busybox sleep 5

# Find latest image in the current date folder
LATEST=`ls -t ${PTH}/${DIR} | /mnt/disc1/busybox head -1`

# Full filename with path
FILE=${PTH}/${DIR}/${LATEST}

# Username for MQTT
USER="your_username"

# Password for MQTT
PSSWD="your_password"

# Send latest image
/mnt/disc1/MONITORING/mosquitto_pub -h 192.168.2.202 -p 1883 -u ${USER} -P ${PSSWD} -t doorbell/push/image -f ${FILE}


exit 0
