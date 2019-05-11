#!/bin/bash

##Set branch to pull from for dependencies
set -ea

: "${DEPENDENCY_BRANCH:=master}"

##Pull variables from github
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/${DEPENDENCY_BRANCH}/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Restore /lib/modules/
rm -rf  /lib/modules
cp -rf  ${D}/backup/modules/ /lib/

##Restore /lib/firmware/
rm -rf  /lib/firmware
cp -rf  ${D}/backup/firmware/ /lib/

##libreelec Mediabuild
cd ${D}
mkdir libreelec-drivers
cd libreelec-drivers
wget -nc https://github.com/LibreELEC/dvb-firmware/archive/${LE}.tar.gz
tar xvf ${LE}.tar.gz

#Copy firmware to /lib/firmware
rsync -av ${D}/libreelec-drivers/dvb-firmware-${LE}/firmware/ /lib/firmware/

#Create /lib/firmware/unraid-media to identify type of DVB build
echo base=\"LibreELEC\" > /lib/firmware/unraid-media
echo driver=\"${LE}\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of DVB build to destination folder
mkdir -p ${D}/${UNRAID_VERSION}/libreelec/
cp /lib/firmware/unraid-media ${D}/${UNRAID_VERSION}/libreelec/

##Make new bzmodules and bzfirmware
mksquashfs /lib/firmware ${D}/${UNRAID_VERSION}/libreelec/bzfirmware -noappend
cp ${D}/${UNRAID_VERSION}/stock/bzmodules-new ${D}/${UNRAID_VERSION}/libreelec/bzmodules

#Package Up bzimage
cp -f ${D}/kernel/arch/x86/boot/bzImage ${D}/${UNRAID_VERSION}/libreelec/bzimage

#MD5 calculation of files
cd ${D}/${UNRAID_VERSION}/libreelec/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum bzimage > bzimage.md5

#SHA256 calculation of files
cd ${D}/${UNRAID_VERSION}/libreelec/
sha256sum bzmodules > bzmodules.sha256
sha256sum bzfirmware > bzfirmware.sha256
sha256sum bzimage > bzimage.sha256

#Copy necessary stock files
cp ${D}/${UNRAID_VERSION}/stock/bzroot* ${D}/${UNRAID_VERSION}/libreelec/

#Return to original directory
cd ${D}
