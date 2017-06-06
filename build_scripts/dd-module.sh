#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Restore /lib/modules/ & /lib/firmware/
umount -l /lib/modules/
umount -l /lib/firmware/
rm -rf  /lib/modules
rm -rf  /lib/firmware
mkdir /lib/modules
mkdir /lib/firmware
mount /boot/bzmodules /lib/modules -t squashfs -o loop
mount /boot/bzfirmware /lib/firmware -t squashfs -o loop

##Unmount bzmodules and make rw
cp -r /lib/modules /tmp
umount -l /lib/modules/
rm -rf  /lib/modules
mv -f  /tmp/modules /lib

##Unount bzfirmware and make rw
cp -r /lib/firmware /tmp
umount -l /lib/firmware/
rm -rf  /lib/firmware
mv -f  /tmp/firmware /lib

##Digital Devices Github
cd /usr/src/

##Pull release from Digital Devices
wget https://github.com/DigitalDevices/dddvb/archive/$DD.tar.gz
tar -xf $DD.tar.gz
cd dddvb-$DD
make
make install

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"Digital Devices \(Github\)\" > /lib/firmware/unraid-media
echo driver=\"$DD\" >> /lib/firmware/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/dd/
cp /lib/firmware/unraid-media $D/$VERSION/dd/

##Make new bzmodules and bzfirmware
mksquashfs /lib/modules $D/$VERSION/dd/bzmodules -noappend
mksquashfs /lib/firmware $D/$VERSION/dd/bzfirmware -noappend

#MD5 calculation of files
cd $D/$VERSION/dd/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzimage* $D/$VERSION/dd/
cp $D/$VERSION/stock/bzroot* $D/$VERSION/dd/

#Return to original directory
cd $D
