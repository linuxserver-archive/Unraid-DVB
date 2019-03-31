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

##Crazy Cat DVB-ST built from LE script

cd ${D}
wget -nc https://raw.githubusercontent.com/CHBMB/LibreELEC.tv/master/tools/mkpkg/mkpkg_media_build
chmod +x mkpkg_media_build
mkpkg_media_build

##Unpack and build from LE package
GIT_REV="$(find media_build-*.tar.xz | cut -c 13-22)"
tar xvf media_build-"${GIT_REV}".tar.xz
cd media_build-"${GIT_REV}"
./build
make install

#Create /lib/firmware/unraid-media to identify type of DVB build
echo base=\"TBS \(CrazyCat\) DVB-S\(2\) \& DVB-T\(2\)\" > /lib/firmware/unraid-media
echo driver=\"${GIT_REV}\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of DVB build to destination folder
mkdir -p ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/
cp /lib/firmware/unraid-media ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/

##Make new bzmodules and bzfirmware
mkdir -p ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/
mksquashfs /lib/modules/$(uname -r)/ ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/bzmodules -keep-as-directory -noappend
mksquashfs /lib/firmware ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/bzfirmware -noappend

#Package Up bzimage
cp -f ${D}/kernel/arch/x86/boot/bzImage ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/bzimage

#MD5 calculation of files
cd ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum bzimage > bzimage.md5

#Copy necessary stock files
cp ${D}/${UNRAID_VERSION}/stock/bzroot* ${D}/${UNRAID_VERSION}/tbs-crazy-dvbst/

#Return to original directory
cd ${D}
