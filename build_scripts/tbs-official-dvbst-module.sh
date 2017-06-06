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

##TBS Mediabuild
cd $D
mkdir tbs-drivers-dvbst
cd $D/tbs-drivers-dvbst
wget -nc http://www.tbsiptv.com/download/common/tbs-linux-drivers_v$TBS.zip
unzip tbs-linux-drivers_v$TBS.zip
tar jxf linux-tbs-drivers.tar.bz2
cd linux-tbs-drivers
./v4l/tbs-x86_64.sh
make -j $(nproc)
make install

#Create /lib/firmware/unraid-media to identify type of mediabuild
echo base=\"TBS \(Official\) DVB-S\(2\) \& DVB-T\(2\)\" > /lib/firmware/unraid-media
echo driver=\"$TBS\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-official-dvbst/
cp /lib/firmware/unraid-media $D/$VERSION/tbs-official-dvbst/

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/stock/
mksquashfs /lib/modules $D/$VERSION/tbs-official-dvbst/bzmodules -noappend
mksquashfs /lib/firmware $D/$VERSION/tbs-official-dvbst/bzfirmware -noappend

#MD5 calculation of files
cd $D/$VERSION/tbs-official-dvbst/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzimage* $D/$VERSION/tbs-official-dvbst/
cp $D/$VERSION/stock/bzroot* $D/$VERSION/tbs-official-dvbst/

#Return to original directory
cd $D
