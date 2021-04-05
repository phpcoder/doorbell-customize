#!/bin/sh


# Check if process is already running
if /mnt/disc1/busybox pgrep -f keyup >/dev/null
then
	echo "Process is running."
else
	echo "Process is not running."


	# Read the PID of npc process
	PID=`/mnt/disc1/busybox pgrep /npc/npc`
	/mnt/disc1/MONITORING/reredirect -m /npc/myfifo $PID

	# Monitor the npc log for a push button message
	while true;
	do
		if /mnt/disc1/busybox grep -q "keyup" /npc/myfifo
		then
				echo "Button is pushed"
				/mnt/disc1/MONITORING/send_bell_mqtt
				/mnt/disc1/MONITORING/send_pic_telegram
		fi
		/mnt/disc1/busybox sleep 2
	done

fi
