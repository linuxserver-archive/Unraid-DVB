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

#Create bzroot-libreelec files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-libreelec

##LibreELEC Mediabuild
cd $D
mkdir libreelec-drivers
cd libreelec-drivers
wget -nc https://github.com/LibreELEC/dvb-firmware/archive/$LE.tar.gz
tar xvf $LE.tar.gz

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-libreelec/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-libreelec/ \;

#Copy firmware to bzroot
rsync -av $D/libreelec-drivers/dvb-firmware-$LE/firmware/ $D/bzroot-libreelec/lib/firmware/

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"LibreELEC\" > $D/bzroot-libreelec/etc/unraid-media
echo driver=\"$LE\" >> $D/bzroot-libreelec/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/libreelec/
cp $D/bzroot-libreelec/etc/unraid-media $D/$VERSION/libreelec/

#Package Up bzroot
cd $D/bzroot-libreelec
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/libreelec/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/libreelec/bzimage

#MD5 calculation of files
cd $D/$VERSION/libreelec/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5

#Return to original directory
cd $D
