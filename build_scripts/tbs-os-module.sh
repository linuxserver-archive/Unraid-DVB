#!/bin/bash

###Run kernel_compile.sh prior to running a module###

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Remove any files remaining in /lib/modules/ & /lib/firmware/
cd $D
find /lib/modules/$(uname -r) -type f -exec rm -rf {} \;
find /lib/firmware -type f -exec rm -rf {} \;

#Restore default /lib/modules/ & /lib/firmware/
rsync -av $D/lib/modules/$(uname -r)/ /lib/modules/$(uname -r)/
rsync -av $D/lib/firmware/ /lib/firmware/

#Create bzroot-tbs files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-tbs-os

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
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C $D/bzroot-tbs-os/lib/firmware/

##Firmware from Current TBS Closed Source Drivers
#mkdir -p $D/tbs-os-firmware/
#cd $D/tbs-os-firmware/
#wget https://github.com/CHBMB/Unraid-DVB/raw/master/files/tbs-firmware.tar.bz2
#tar jxvf tbs-firmware.tar.bz2 -C $D/bzroot-tbs-os/lib/firmware/

##libreelec Mediabuild
cd $D
mkdir libreelec-drivers
cd libreelec-drivers
wget -nc https://github.com/LibreELEC/dvb-firmware/archive/$LE.tar.gz
tar xvf $LE.tar.gz 

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-tbs-os/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-tbs-os/ \;

#Copy librelec firmware to bzroot
rsync -av $D/libreelec-drivers/dvb-firmware-$LE/firmware/ $D/bzroot-tbs-os/lib/firmware/

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"TBS \(Open Source\) ATSC-C, DVB-C, DVB-S\(2\) \& DVB-T\(2\)\ with extra firmware to support more cards" > $D/bzroot-tbs-os/etc/unraid-media
echo driver=\"$DATE\" >> $D/bzroot-tbs-os/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-os/
cp $D/bzroot-tbs-os/etc/unraid-media $D/$VERSION/tbs-os/

#Package Up bzroot
cd $D/bzroot-tbs-os
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/tbs-os/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/tbs-os/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/tbs-os/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/tbs-os/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
