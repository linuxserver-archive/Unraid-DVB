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
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-crazy

##Crazy Cat DVB build
cd $D
mkdir tbs-drivers
cd $D/tbs-drivers
wget -nc https://bitbucket.org/CrazyCat/linux-tbs-drivers/get/master.tar.bz2
tar xjvf master.tar.bz2
cd linux-tbs-drivers
./v4l/tbs-x86_64.sh
make -j $(nproc)
make install

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-crazy/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-crazy/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"crazy\" > $D/bzroot-crazy/etc/unraid-media
echo driver=\"$DATE\" >> $D/bzroot-crazy/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/crazy/
cp $D/bzroot-tbs/etc/unraid-media $D/$VERSION/crazy/

#Package Up bzroot
cd $D/bzroot-crazy
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/crazy/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/crazy/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/crazy/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/crazy/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
