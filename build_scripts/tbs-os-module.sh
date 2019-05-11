#!/bin/bash

##Set branch to pull from for dependencies
set -ea

: "${DEPENDENCY_BRANCH:=master}"

##Pull variables from github
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/${DEPENDENCY_BRANCH}/build_scripts/variables.sh
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/${DEPENDENCY_BRANCH}/build_scripts/dvb-variables.sh

source ./variables.sh

if [[ -z "$D" ]]; then
    echo "Must provide D in environment" 1>&2
    exit 1
fi

source ${D}/dvb-variables.sh

##Restore /lib/modules/
rm -rf  /lib/modules
cp -rf  ${D}/backup/modules/ /lib/

##Restore /lib/firmware/
rm -rf  /lib/firmware
cp -rf  ${D}/backup/firmware/ /lib/

##Open Source DVB-ST build
cd ${D}
git clone https://github.com/tbsdtv/media_build.git
git clone --depth=1 https://github.com/tbsdtv/linux_media.git -b latest ./media
cd media_build
make dir DIR=../media
make distclean
make -j $(grep -c ^processor /proc/cpuinfo)
make install

##Firmware from Current TBS Closed Source Drivers
mkdir -p ${D}/tbs-os-firmware/
cd ${D}/tbs-os-firmware/
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/

##Compatible dvb-fe-cx24117.fw
if [ -e ${D}/libreelec-drivers/dvb-firmware-${LE}/firmware/dvb-fe-cx24117.fw ]; then
   cp ${D}/libreelec-drivers/dvb-firmware-${LE}/firmware/dvb-fe-cx24117.fw /lib/firmware/dvb-fe-cx24117.fw
else
   cd ${D}
   mkdir libreelec-drivers
   cd libreelec-drivers
   wget -nc https://github.com/LibreELEC/dvb-firmware/archive/${LE}.tar.gz
   tar xvf ${LE}.tar.gz
   cp ${D}/libreelec-drivers/dvb-firmware-${LE}/firmware/dvb-fe-cx24117.fw /lib/firmware/dvb-fe-cx24117.fw
fi

#Create /lib/firmware/unraid-media to identify type of DVB build
echo base=\"TBS \(Open Source\) \& LibreELEC ATSC-C, DVB-C, DVB-S\(2\) \& DVB-T\(2\)\" > /lib/firmware/unraid-media
echo driver=\"${DATE}\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of DVB build to destination folder
mkdir -p ${D}/${UNRAID_VERSION}/tbs-os/
cp /lib/firmware/unraid-media ${D}/${UNRAID_VERSION}/tbs-os/

##Make new bzmodules and bzfirmware
mkdir -p ${D}/${UNRAID_VERSION}/tbs-os/
mksquashfs /lib/modules/$(uname -r)/ ${D}/${UNRAID_VERSION}/tbs-os/bzmodules -keep-as-directory -noappend
mksquashfs /lib/firmware ${D}/${UNRAID_VERSION}/tbs-os/bzfirmware -noappend

#Package Up bzimage
cp -f ${D}/kernel/arch/x86/boot/bzImage ${D}/${UNRAID_VERSION}/tbs-os/bzimage

#MD5 calculation of files
cd ${D}/${UNRAID_VERSION}/tbs-os/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum bzimage > bzimage.md5

#SHA256 calculation of files
cd ${D}/${UNRAID_VERSION}/tbs-os/
sha256sum bzmodules > bzmodules.sha256
sha256sum bzfirmware > bzfirmware.sha256
sha256sum bzimage > bzimage.sha256

#Copy necessary stock files
cp ${D}/${UNRAID_VERSION}/stock/bzroot* ${D}/${UNRAID_VERSION}/tbs-os/

#Return to original directory
cd ${D}
