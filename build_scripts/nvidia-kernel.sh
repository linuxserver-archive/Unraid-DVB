#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/nvidia-variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Restore /lib/modules/
rm -rf  /lib/modules
cp -rf  $D/backup/modules/ /lib/

##Restore /lib/firmware/
rm -rf  /lib/firmware
cp -rf $D/backup/firmware/ /lib/

##Get Slackbuild for nvidia-kernel
cd $D
wget https://slackbuilds.org/slackbuilds/14.2/system/nvidia-kernel.tar.gz

##Get Nvidia Kernel Version
mkdir nvidia-kernel
tar xvf nvidia-kernel.tar.gz
cd nvidia-kernel
NVIDIAKERNEL=$(grep -E VERSION nvidia-kernel.info | cut -d '"' -f2)

##Get Nvidia Kernel Source Files
wget https://download.nvidia.com/XFree86/Linux-x86_64/$NVIDIAKERNEL/NVIDIA-Linux-x86_64-$NVIDIAKERNEL.run

##Make Nvidia Kernel Package
cd $D/nvidia-kernel
chmod +x nvidia-kernel.SlackBuild
./nvidia-kernel.SlackBuild

##Install Nvidia Kernel Package
installpkg /tmp/nvidia-kernel-*.tgz

#Create /lib/firmware/unraid-media to identify type of build
echo base=\"Nvidia\" > /lib/firmware/unraid-media
echo driver=\"$NVIDIA\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of DVB build to destination folder
mkdir -p $D/$VERSION/nvidia/
cp /lib/firmware/unraid-media $D/$VERSION/nvidia/

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/nvidia/
mksquashfs /lib/modules/$(uname -r)/ $D/$VERSION/nvidia/bzmodules -keep-as-directory -noappend
mksquashfs /lib/firmware $D/$VERSION/nvidia/bzfirmware -noappend

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/nvidia/bzimage

#MD5 calculation of files
cd $D/$VERSION/nvidia/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum bzimage > bzimage.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzroot* $D/$VERSION/nvidia/

#Return to original directory
cd $D
