# Customize HiSilicon Linux based Video Doorbells
This project describes some ideas on customizaiton of Smart Video Doorbells (HiSilicon hi3518ev200 SoC) compatible with Yoosee type of firmware. The method adds new functionality to stock devices:
* sending messages to a MQTT broker, e.g. on ring button push
* sending messages to a Telegram bot with attached images e.g. on ring button push
* sending PushOver notifactions with attached image on button press
* adds busybox with extended command set
* adds cron jobs e.g. to reboot the device on schedule or clean up file directorys.

Additionally, for extra security it is possible 
* to disable Wifi daemon if the doorbell uses wired network connection,
* to install a firewall to prevent "calling home" by the doorbell firmware, however it also disconnects compatible mobile apps.
Such solution is not covered by the current version of the project. 


## Compatible devices
There are many video doorbell devices and IP cameras available from various makers with similar hardware. Many of them are designed to be compatible with firmware from a few major firmware makers, notably Gwelltimes or Yoosee. This project covers doorbell devices with firmware named as 13.xx.xx.xx with HiSilicon hi3518ev200 SoC onboard. Compatibility with other devices is not tested.

## Installing modified firmware
Patched Firmware 13.01.01.31 based on 13.01.01.30
* Has Telnet enabled
* Has FPS fix, steady on 15fps
* Stays up&running > 3 days, even when disconnected from WAN

Instructions to install:
Download the [Firmware](https://github.com/cmdwhoami/doorbell-customize/archive/refs/heads/main.zip) and unzip.
Go to file SDcard and copy contents ie: (CRON, MONITORING, UTILITIES, busybox, nano, npcupg.bin, set_time.sh, and weget) on root of (empty) SD card
Insert SD card into slot on Doorbell
Open YooSee App -> Settings -> Firmware and select install. This will install the local firmware from SD.


## Alternitive: Add telnet and repacking stock firmware yourself
Customization described in this project requires an access to the divice Linux CLI. By default the device firmware disables external telnet access. To enable it, it is necessary to get to the doorbell's PCB and have an extra UART TTL device attached to proper pads which then connects to the device Linux console. PCBs from different makers may vary in UART pin location. However, it maybe possible to enable telnet without opening the case. It requires flashing a custom firmware with a telnet daemon running.

It is easy to unpack the downloaded Yoosee firmware package and add a few lines of code into `/npc/dhcp.script` to start a telnet daemon at boot time:

```bash
echo "** Start telnetd"
/usr/sbin/telnetd
```
However, flashing of a modified firmware into your device will be impossible: the package needs to be signed. Fortunately the [Firmware packing tools](https://github.com/zzerrg/gmfwtools) by @zzerrg are here to help. The unpacking/packing process is described there in detail. The latest firmware version successfully repacked by the author with the described methods is 13.01.00.98.

A repacked firmware shall be copied to the SD card root as `npcupg.bin`. The Yoosee mobile app will indicate the update available, and after updating the doorbell can be accessed via telnet using the doorbell's IP and user `root` without password.

```
$ telnet 192.168.1.2
Trying 192.168.1.2...
Connected to 192.168.1.2.
Escape character is '^]'.

(none) login: root
Welcome to HiLinux.
```


## CPU and device info
After successful login the information on the SoC used in the device can be seen. The system customized in this project shows the following info:

```bash
cat /proc/cpuinfo
Processor       : ARM926EJ-S rev 5 (v5l)
BogoMIPS        : 269.10
Features        : swp half fastmult edsp java 
CPU implementer : 0x41
CPU architecture: 5TEJ
CPU variant     : 0x0
CPU part        : 0x926
CPU revision    : 5

Hardware        : hi3518ev200
Revision        : 0000
Serial          : 0000000000000000
```

The Linux version can be checked too, but to see it, you need a busybox binary with an extended command set. The space on a device's writable partition `/npc` is limited and almost full with the files supplied by the firmware:

```bash
/mnt/disc1/busybox df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root                 2.5M      2.5M         0 100% /
tmpfs                    11.9M      4.0K     11.9M   0% /dev
/dev/ram0                62.0M      1.3M     57.4M   2% /mnt/ramdisk
/dev/ram0                62.0M      1.3M     57.4M   2% /etc
/dev/ram0                62.0M      1.3M     57.4M   2% /tmp
/dev/mtdblock3          320.0K    208.0K    112.0K  65% /rom
/dev/mtdblock4            2.8M      2.7M     80.0K  97% /npc
/dev/mmcblk0p1            7.5G     52.0M      7.5G   1% /mnt/disc1
```
A remaining space is enough only for a few scripts, but for any binary it may not be enough. Therefore all necessary files should be placed on an SD card mounted at `/mnt/disc1`. For a convenience, this project repository contains some binaries cross-compiled for HiSilicon SoC. With the help of a provided [busybox binary](SDcard/busybox) placed to SD card root, the Linux version, as well as a mentioned partition list `df -h` shown above can be seen:

```
# /mnt/disc1/busybox uname -a
Linux (none) 3.4.35 #61 Wed Aug 30 18:45:19 CST 2017 armv5tejl GNU/Linux
```

## Customizing your doorbell
Provided you succeeded with a repacking of a telnet enabled firmware, or found a compatible custom firmware pack elsewhere, you can start adding new functionality. In fact, no other firmware modification is necessary. Everything else is added to the existing writable partition and to the external SD card. 

1. Add the following code into `/npc/dhcp.script` together with previously added telnet code:

```bash
echo "** Start telnetd"
/usr/sbin/telnetd
# echo "** Disable WLAN"
# /sbin/ifconfig wlan0 down
# echo "** Start ftpd"
# /mnt/disc1/busybox tcpsvd -vE 0.0.0.0 21 ftpd -w /
echo "** Start monitoring"
/mnt/disc1/MONITORING/parse_push &
echo "** Start Cron"
/mnt/disc1/busybox crond -L /mnt/disc1/CRON/cron.log -l 0 -c /mnt/disc1/CRON/
```
Please note optional lines for starting FTP daemon and disabling wlan. Given example code can be run at any time e.g. via telnet to start ftpd and transfer files to/from SD card. A modified [dhcp.script](dhcp.script) is provided.

2. Copy files in [SDcard](SDcard/) to your SD card root if you havent already by downloaded the zipfile. 
3. Add xecutable permission to scrpts and binaries by `find /mnt/disc1/MONITORING/ -type f -iname "*.sh" -exec chmod +x {} \;`

Following is a short description of the provided files.
	* [MONITORING](SDcard/MONITORING) Contains binaries and scripts for monitoring ring button keypress, MQTT message publishing and Telegram bot messaging.
	* [UTILITIES](SDcard/UTILITIES) Contains TERMINFO for terminal support and some useful binaries.
	* [CRON](SDcard/CRON) Contains files to support cron jobs.

3. Using the included busybox binary create a named pipe and modify file ownership and permission. This will complete writable partition modifications.

```bash
/mnt/disc1/busybox chmod 744 /npc/dhcp.script
/mnt/disc1/busybox chown 1011:1011 /npc/dhcp.script
/mnt/disc1/busybox mkfifo /npc/myfifo
/mnt/disc1/busybox chown 1011:1011 /npc/myfifo
```

4. Modify the example scripts to include your own data:
	* `MONITORING/send_bell_mqtt` - fill in your MQTT broker's IP/Port number and modify topic/message
	* `MONITORING/send_pic_telegram` - fill in your Telegram bot info: `BOT ID:BOT TOKEN` and `CHAT ID`. To be able use image attachment, taking snapshots on button press by the alarm option has already been enabled in the repacked firmware.
	* 'MONITORING/pushover.sh' - edit `USER_KEY` and `APP_TOKEN` with your user key and app token.


## How it works
All stock functionality of compatible doorbell/IP cam devices is coded into a single binary `/npc/npc`. Reverse engineering of this undocumented code to incorporate new functions would be a tedious job. A simpler approach would be to augment the existing functionality with some extra features using standard Linux system means.

To detect a push of a doorbell ring button a monitoring of `/npc/npc` log is added by `/mnt/disc1/MONITORING/parse_push` shell script. It is made possible using `reredirect` - a tool to dynamically redirect outputs of any running program. All "magic" is done by catching a string "keyup" from the log produced by `/npc/npc`. When it is found, further actions such as sending MQTT or Telegram messages are triggered.

Log analyzing makes possible adding more functions, it is limited only by your imagination and verbosity of logging. Stock functions are not affected if new additions do not degrade the CPU performance. With a compatible doorbell mobile app it is still possible to monitor video streams, remotely unlock the door and use voice interaction with a visitor. Unfortunately, all these goodies are available with the help of app's cloud servers automatically connected by the doorbell firmware. If the app is not needed, cloud servers can be blocked, however all individual device settings are stored in the cloud.


## Cross-compile binaries for arm5l
This project includes some binaries suitable for the use with a compatible hardware. In case you want to customize the devices with a different CPU type, you need to set up your own toolchain.

To create binaries working on a target architecture such as `HiSilicon hi3518ev200 arm5l` you need to cross-compile those binaries using an appropriate toolchain and configuring [buildroot](http://nightly.buildroot.org/manual.html#_buildroot_quick_start). Detailed instructions can be found elsewhere. As a side note, for the target `HiSilicon hi3518ev200 arm5l` the compiler `arm-buildroot-linux-uclibcgnueabi-gcc` was used with the following compilation flags:

```
CFLAGS=-Wall --static -O2
CFLAGS+=-march=armv5te -mcpu=arm926ej-s -mtune=arm926ej-s -msoft-float -mfloat-abi=soft
```

To create binaries, needed for this project, the following libraries should be cross-compiled first:
* [OpenSSL](https://github.com/openssl/openssl)
* [Zlib](https://www.zlib.net/)


Finally, some instructions on the required binaries:
* [busybox](https://www.busybox.net/)
* [reredirect](https://github.com/jerome-pouiller/reredirect/)
* [curl](http://www.matteomattei.com/how-to-cross-compile-curl-library-with-ssl-and-zlib-support/)
* [mosquitto_pub](https://github.com/eclipse/mosquitto)


## Credits
This project would not be possible without the work of other authors:

* [@zzerrg](https://github.com/zzerrg/gmfwtools) Firmware packing tools.
* [Jérôme Pouiller](https://github.com/jerome-pouiller/reredirect/) reredirect - a tool to dynamically redirect outputs of a running program.
* [@riogrande75](https://github.com/riogrande75/doorbell/) - some ideas and useful contribution in forums by @riogrande75, who was the first to customize similar devices.

## Links
Some useful links to the forums and other resources.
* [Domoticz Forum](https://www.domoticz.com/forum/viewtopic.php?p=71267) - discussion of integration of the doorbells into a Smart Home system.
* [IPCamtalk Forum](https://ipcamtalk.com/threads/yoosee-sd-m5-doorbell-1080p-poe-rtsp-onvif-only-66.40569/) - ideas of possible customization of YooSee SD-M5 doorbell.

## License
Released under the [MIT License](http://www.opensource.org/licenses/mit-license.php) - see the [LICENSE](LICENSE) file for details.
