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

#Create bzroot-ddexp files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-ddexp

##Mediabuild Experimental
cd $D
hg clone http://linuxtv.org/hg/~endriss/media_build_experimental/
cd media_build_experimental
make download
make untar
make -j $(nproc)
make install
#wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/ddbridge.conf

#Copy firmware to bzroot
rsync -av $D/media_build_experimental/ddbridge.conf $D/bzroot-ddexp/etc/modprobe.d/ddbridge.conf
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-ddexp/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-ddexp/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"Digital Devices Experimental\" > $D/bzroot-ddexp/etc/unraid-media
echo driver=\"$DATE\" >> $D/bzroot-ddexp/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/ddexp/
cp $D/bzroot-ddexp/etc/unraid-media $D/$VERSION/ddexp/

#Package Up bzroot
cd $D/bzroot-ddexp
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/ddexp/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/ddexp/bzimage

#MD5 calculation of files
cd $D/$VERSION/ddexp/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5

#Return to original directory
cd $D
