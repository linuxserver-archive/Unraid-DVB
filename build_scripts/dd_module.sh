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

#Create bzroot-ddgit files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-dd

##Digital Devices Github
cd /usr/src/

##Pull release from Digital Devices
#wget https://github.com/DigitalDevices/dddvb/archive/$DD.tar.gz
#tar -xf $DD.tar.gz
#cd dddvb-$DD

##Pull release from my fork
wget https://github.com/CHBMB/dddvb/archive/master.zip
unzip master.zip
cd dddvb-master

##Common to both
make
make install
mkdir -p /etc/depmod.d
echo 'search extra updates built-in' | tee /etc/depmod.d/extra.conf
depmod -a

#Symlink ddbridge.conf
#ln -s /boot/config/plugins/UnraidDVB/ddbridge.conf $D/bzroot-dd/etc/modprobe.d/ddbridge.conf

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-dd/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-dd/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"Digital Devices \(Github\)\" > $D/bzroot-dd/etc/unraid-media
echo driver=\"$DD\" >> $D/bzroot-dd/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/dd/
cp $D/bzroot-dd/etc/unraid-media $D/$VERSION/dd/

#Package Up bzroot
cd $D/bzroot-dd
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/dd/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/dd/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/dd/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/dd/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
