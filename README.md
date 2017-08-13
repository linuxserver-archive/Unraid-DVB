![https://linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)

# Unraid-DVB

In order to use TVHeadEnd or MythTV with PCIe or USB DVB Tuners you need to run a special Unraid build which contains the necessary drivers.  

This replaces the Unraid bzmodules and bzfirmware files with newly created ones that have drivers for DVB hardware incorporated.

These are not necessary if you use Homerun or IPTV devices.

## There are two steps necessary to getting a PVR Solution running on your Unraid Machine

1.  Installation Of unRAID DVB Plugin
2.  Installation Of PVR Software: TVHeadEnd Docker, TVHeadEnd Plugin or MythTV Docker

