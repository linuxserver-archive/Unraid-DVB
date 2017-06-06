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
mkdir tbs-drivers-dvbc
cd $D/tbs-drivers-dvbc
wget -nc http://www.tbsiptv.com/download/common/tbs-linux-drivers_v$TBS.zip
unzip tbs-linux-drivers_v$TBS.zip
tar jxf linux-tbs-drivers.tar.bz2
cd linux-tbs-drivers
./v4l/tbs-x86_64.sh
./v4l/tbs-dvbc-x86_64.sh
make -j $(nproc)
make install

#Create /lib/firmware/unraid-media to identify type of mediabuild
echo base=\"TBS \(Official\) DVB-C\" > /lib/firmware/unraid-media
echo driver=\"$TBS\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-official-dvbc/
cp /lib/firmware/unraid-media $D/$VERSION/tbs-official-dvbc/

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/stock/
mksquashfs /lib/modules $D/$VERSION/tbs-official-dvbc/bzmodules -noappend
mksquashfs /lib/firmware $D/$VERSION/tbs-official-dvbc/bzfirmware -noappend

#MD5 calculation of files
cd $D/$VERSION/tbs-official-dvbc/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzimage* $D/$VERSION/tbs-official-dvbc/
cp $D/$VERSION/stock/bzroot* $D/$VERSION/tbs-official-dvbc/

#Return to original directory
cd $D
