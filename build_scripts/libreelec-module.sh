#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Restore /lib/modules/
rm -rf  /lib/modules
cp -rf  $D/backup/modules/ /lib/

##Restore /lib/firmware/
rm -rf  /lib/firmware
cp -rf  $D/backup/firmware/ /lib/

##libreelec Mediabuild
cd $D
mkdir libreelec-drivers
cd libreelec-drivers
wget -nc https://github.com/LibreELEC/dvb-firmware/archive/$LE.tar.gz
tar xvf $LE.tar.gz

#Copy firmware to /lib/firmware
rsync -av $D/libreelec-drivers/dvb-firmware-$LE/firmware/ /lib/firmware/

#Create /lib/firmware/unraid-media to identify type of DVB build
echo base=\"LibreELEC\" > /lib/firmware/unraid-media
echo driver=\"$LE\" >> /lib/firmware/unraid-media

#Copy /lib/firmware/unraid-media to identify type of DVB build to destination folder
mkdir -p $D/$VERSION/libreelec/
cp /lib/firmware/unraid-media $D/$VERSION/libreelec/

##Make new bzmodules and bzfirmware
mksquashfs /lib/firmware $D/$VERSION/libreelec/bzfirmware -noappend
cp /boot/bzmodules $D/$VERSION/libreelec/bzmodules

#MD5 calculation of files
cd $D/$VERSION/libreelec/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5

#Copy necessary stock files
cp $D/$VERSION/stock/bzimage* $D/$VERSION/libreelec/
cp $D/$VERSION/stock/bzroot* $D/$VERSION/libreelec/

#Return to original directory
cd $D
