#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Restore /lib/modules/
rm -rf  /lib/modules
cp -rf  ${D}/backup/modules/ /lib/

##Restore /lib/firmware/
rm -rf  /lib/firmware
cp -rf  ${D}/backup/firmware/ /lib/

##Digital Devices Github
cd /usr/src/

##Pull release from Digital Devices
wget https://github.com/DigitalDevices/dddvb/archive/${DD}.tar.gz
tar -xf ${DD}.tar.gz
cd dddvb-${DD}
make -j $(grep -c ^processor /proc/cpuinfo)
make install

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"Digital Devices \(Github\)\" > /lib/firmware/unraid-media
echo driver=\"${DD}\" >> /lib/firmware/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p ${D}/${UNRAID_VERSION}/dd/
cp /lib/firmware/unraid-media ${D}/${UNRAID_VERSION}/dd/

##Make new bzmodules and bzfirmware
mksquashfs /lib/modules/$(uname -r)/ ${D}/${UNRAID_VERSION}/dd/bzmodules -keep-as-directory -noappend
mksquashfs /lib/firmware ${D}/${UNRAID_VERSION}/dd/bzfirmware -noappend

#Package Up bzimage
cp -f ${D}/kernel/arch/x86/boot/bzImage ${D}/${UNRAID_VERSION}/dd/bzimage

#MD5 calculation of files
cd ${D}/${UNRAID_VERSION}/dd/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum bzimage > bzimage.md5

#Copy necessary stock files
cp ${D}/${UNRAID_VERSION}/stock/bzroot* ${D}/${UNRAID_VERSION}/dd/

#Return to original directory
cd ${D}
