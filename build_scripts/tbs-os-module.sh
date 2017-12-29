#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Restore /lib/modules/
rm -rf  /lib/modules
cp -rf  $D/backup/modules/ /lib/

##Restore /lib/firmware/
rm -rf  /lib/firmware
cp -rf  $D/backup/firmware/ /lib/

##Open Source DVB-ST build
cd $D
git clone https://github.com/tbsdtv/media_build.git
git clone --depth=1 https://github.com/tbsdtv/linux_media.git -b latest ./media
cd media_build
make dir DIR=../media
make distclean
make
make install

##Firmware from Current TBS Closed Source Drivers
mkdir -p $D/tbs-os-firmware/
cd $D/tbs-os-firmware/
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/

#Create /lib/firmware/unraid-media to identify type of DVB build
echo base=\"TBS \(Open Source\) \& LibreELEC ATSC-C, DVB-C, DVB-S\(2\) \& DVB-T\(2\)\" > /lib/firmware/unraid-media
echo driver=\"$DATE\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of DVB build to destination folder
mkdir -p $D/$VERSION/tbs-os/
cp /lib/firmware/unraid-media $D/$VERSION/tbs-os/

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/tbs-os/
mksquashfs /lib/modules/$(uname -r)/ $D/$VERSION/tbs-os/bzmodules -keep-as-directory -noappend
mksquashfs /lib/firmware $D/$VERSION/tbs-os/bzfirmware -noappend

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/tbs-os/bzimage

#MD5 calculation of files
cd $D/$VERSION/tbs-os/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum bzimage > bzimage.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzroot* $D/$VERSION/tbs-os/

#Return to original directory
cd $D
