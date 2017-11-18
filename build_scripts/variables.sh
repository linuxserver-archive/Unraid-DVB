#!/bin/bash

# set our package list
slack_package_current=(\
autoconf \
automake \
bc \
binutils \
cpio \
flex \
gc \
gcc \
gcc-g++ \
git \
glibc \
glibc-solibs \
guile \
kernel-headers \
kernel-modules \
lftp \
libcgroup \
libgudev \
libmpc \
libtool \
libunistring \
m4 \
make \
mpfr \
ncurses \
patch \
perl \
pkg-config \
python \
readline \
sqlite \
squashfs-tools \
)

# current RocketRaid Release - See http://www.highpoint-tech.com/BIOS_Driver/R750/Linux/
ROCKET="1.2.10.1-17_01_23"

ROCKETSHORT=$(echo $ROCKET | cut -d"-" -f1)

# current LibreELEC Release - See https://github.com/LibreELEC/dvb-firmware/releases
LE="1.2.2"

# current Digital Devices Github release - See https://github.com/DigitalDevices/dddvb/releases
DD="0.9.32-compile-fix"

# current Date (DDExp & TBS OS Version)
DATE=$(date +'%d%m%y')

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# clean up old files if they exist
[[ -f "$D"/FILE_LIST_CURRENT ]] && rm "$D"/FILE_LIST_CURRENT
[[ -f "$D"/URLS_CURRENT ]] && rm "$D"/URLS_CURRENT

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"

# get slackware64-current FILE_LIST
wget -nc http://mirrors.slackware.com/slackware/slackware64-current/slackware64/FILE_LIST -O $D/FILE_LIST_CURRENT

slack_package_current_urlbase="http://mirrors.slackware.com/slackware/slackware64-current/slackware64"

for i in "${slack_package_current[@]}"
do
package_locations_current=$(grep "\<$i-[[:digit:]].*.txz$" FILE_LIST_CURRENT | cut -b 53-9001)
echo "$slack_package_current_urlbase""$package_locations_current" >> "$D"/URLS_CURRENT
done
