#!/bin/sh

# This example publishes two MQTT messages for DOMOTICZ Home Automation system
# Fill in your MQTT broker's IP/Port number and topic/message

/mnt/disc1/MONITORING/mosquitto_pub -h 192.168.1.3 -p 1883  -t "domoticz/in" -m '{"command":"switchlight", 
"idx" : 79, "switchcmd": "On"}'
/mnt/disc1/MONITORING/mosquitto_pub -h 192.168.1.3 -p 1883  -t "domoticz/in" -m '{"command":"switchlight", 
"idx" : 119, "switchcmd": "On"}'

