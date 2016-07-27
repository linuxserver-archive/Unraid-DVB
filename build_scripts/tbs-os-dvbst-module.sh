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
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-tbs-os-dvbst

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


#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-tbs-os-dvbst/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-tbs-os-dvbst/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"TBS \(Open Source\) DVB-S\(2\) \& DVB-T\(2\)\" > $D/bzroot-tbs-os-dvbst/etc/unraid-media
echo driver=\"$DATE\" >> $D/bzroot-tbs-os-dvbst/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-os-dvbst/
cp $D/bzroot-tbs-os-dvbst/etc/unraid-media $D/$VERSION/tbs-os-dvbst/

#Package Up bzroot
cd $D/bzroot-tbs-os-dvbst
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/tbs-os-dvbst/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/tbs-os-dvbst/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/tbs-os-dvbst/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/tbs-os-dvbst/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
