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

#Create bzroot-ceton files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-ceton

##Pull release
wget https://github.com/JamesRHarris/infinitv_pcie/archive/master.zip
unzip master.zip
cd infinitv_pcie-master/
make
make install

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-ceton/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-ceton/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"InfiniTV" > $D/bzroot-ceton/etc/unraid-media
echo driver=\"$DATE\" >> $D/bzroot-ceton/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/ceton/
cp $D/bzroot-dd/etc/unraid-media $D/$VERSION/ceton/

#Package Up bzroot
cd $D/bzroot-ceton
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/ceton/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/ceton/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/ceton/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/ceton/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
