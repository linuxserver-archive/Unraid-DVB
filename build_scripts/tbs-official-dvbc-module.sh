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
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-tbs-official-dvbc

##TBS Mediabuild
cd $D
mkdir tbs-drivers-dvbc
cd $D/tbs-drivers-dvbc
wget -nc http://www.tbsdtv.com/download/document/common/tbs-linux-drivers_v$TBS.zip
unzip tbs-linux-drivers_v$TBS.zip
tar jxf linux-tbs-drivers.tar.bz2
cd linux-tbs-drivers
./v4l/tbs-x86_64.sh
./v4l/tbs-dvbc-x86_64.sh
make -j $(nproc)
make install

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-tbs-official-dvbc/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-tbs-official-dvbc/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"TBS \(Official\) DVB-C\" > $D/bzroot-tbs-official-dvbc/etc/unraid-media
echo driver=\"$TBS\" >> $D/bzroot-tbs-official-dvbc/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-official-dvbc/
cp $D/bzroot-tbs-official-dvbc/etc/unraid-media $D/$VERSION/tbs-official-dvbc/

#Package Up bzroot
cd $D/bzroot-tbs-official-dvbc
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/tbs-official-dvbc/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/tbs-official-dvbc/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/tbs-official-dvbc/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/tbs-official-dvbc/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
