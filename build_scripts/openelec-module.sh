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

#Create bzroot-openelec files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-openelec

##Openelec Mediabuild
cd $D
mkdir openelec-drivers
cd openelec-drivers
wget -nc https://github.com/CvH/dvb-firmware/archive/CvH-$OE.tar.gz
tar xvf CvH-$OE.tar.gz

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-openelec/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-openelec/ \;

#Copy firmware to bzroot
rsync -av $D/openelec-drivers/dvb-firmware-CvH-$OE/firmware/ $D/bzroot-openelec/lib/firmware/

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"OpenELEC\" > $D/bzroot-openelec/etc/unraid-media
echo driver=\"$OE\" >> $D/bzroot-openelec/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/openelec/
cp $D/bzroot-openelec/etc/unraid-media $D/$VERSION/openelec/

#Package Up bzroot
cd $D/bzroot-openelec
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/openelec/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/openelec/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/openelec/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/openelec/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
