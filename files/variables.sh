#!/bin/bash

# set our package list
slack_package_current=(autoconf automake binutils cpio flex gc gcc gcc-g++ git glibc glibc-solibs guile kernel-headers kernel-modules libcgroup libgudev libmpc libtool libunistring m4 make mercurial mpfr ncurses patch perl pkg-config python sqlite)
slack_package_142=(bc lftp)

# current TBS Drivers See http://www.tbsiptv.com/downloads?path=3
TBS="161031"

# current LibreELEC Release - See https://github.com/LibreELEC/dvb-firmware/releases
LE="1.2.1"

# current Digital Devices Github release - See https://github.com/DigitalDevices/dddvb/releases
DD="0.9.28"

# current Date (DDExp & TBS OS Version)
DATE=$(date +'%d%m%y')

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# clean up old files if they exist
[[ -f "$D"/FILE_LIST ]] && rm "$D"/FILE_LIST
[[ -f "$D"/URLS ]] && rm "$D"/URLS

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"

# get slackware64-current FILE_LIST
wget -nc http://mirrors.slackware.com/slackware/slackware64-current/slackware64/FILE_LIST -O $D/FILE_LIST_CURRENT

slack_package_current_urlbase="http://mirrors.slackware.com/slackware/slackware64-current/slackware64"

for i in "${slack_package_current[@]}"
do
package_locations=$(grep "\<$i-[[:digit:]].*.txz$" FILE_LIST_CURRENT | cut -b 53-9001)
echo "$slack_package_current_urlbase""$package_locations" >> "$D"/CURRENTURLS
done
echo "$python_url" >> "$D"/CURRENTURLS

# get slackware64-14.2 FILE_LIST
wget -nc http://mirrors.slackware.com/slackware/slackware64-14.2/slackware64/FILE_LIST -O $D/FILE_LIST_142

slack_package_142_urlbase="http://mirrors.slackware.com/slackware/slackware64-14.2/slackware64"

for i in "${slack_package_142[@]}"
do
package_locations=$(grep "\<$i-[[:digit:]].*.txz$" FILE_LIST_142 | cut -b 53-9001)
echo "$slack_package_142_urlbase""$package_locations" >> "$D"/142URLS
done
