#!/bin/sh

# Sends a message to a Telegram bot with an attached image.
# Alarm with taking snapshot should be enabled in the doorbell

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
# Fill in your Telegram bot info: <BOT ID>:<BOT TOKEN> and <CHAT ID>
/mnt/disc1/MONITORING/curl --cacert /mnt/disc1/MONITORING/cacert.pem \
-ks -X POST "https://api.telegram.org/<BOT ID>:<BOT TOKEN>/sendPhoto?chat_id=<CHAT ID>" \
-F photo=@${FILE} \
-F caption="Doorbell ring !!! ${LATEST} - Created at ${FDATE}"  > /dev/null
