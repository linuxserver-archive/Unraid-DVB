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

##Crazy Cat DVB-ST built from LE script
cd $D
wget -nc https://raw.githubusercontent.com/LibreELEC/LibreELEC.tv/master/tools/mkpkg/mkpkg_media_build
chmod +x mkpkg_media_build
mkpkg_media_build

##Unpack and build from LE package
GIT_REV="$(find media_build-*.tar.xz | cut -c 13-22)"
tar xvf media_build-"$GIT_REV".tar.xz
cd media_build-"$GIT_REV"
./build
make install

#Create /lib/firmware/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"TBS \(CrazyCat\) DVB-S\(2\) \& DVB-T\(2\)\" > /lib/firmware/unraid-media
echo driver=\"$GIT_REV\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-crazy-dvbst/
cp /lib/firmware/unraid-media $D/$VERSION/tbs-crazy-dvbst/

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/tbs-crazy-dvbst/
mksquashfs /lib/modules $D/$VERSION/tbs-crazy-dvbst/bzmodules -noappend
mksquashfs /lib/firmware $D/$VERSION/tbs-crazy-dvbst/bzfirmware -noappend

#MD5 calculation of files
cd $D/$VERSION/tbs-crazy-dvbst/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzimage* $D/$VERSION/tbs-crazy-dvbst/
cp $D/$VERSION/stock/bzroot* $D/$VERSION/tbs-crazy-dvbst/

#Return to original directory
cd $D
