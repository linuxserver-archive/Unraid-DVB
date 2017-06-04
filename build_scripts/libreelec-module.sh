#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Install packages
[ ! -d "$D/packages" ] && mkdir $D/packages
  wget -nc -P $D/packages -i $D/URLS_CURRENT
  installpkg $D/packages/*.*

#Download patchutils & Proc-ProcessTable
mkdir $D/packages
cd $D/packages
wget -nc https://github.com/CHBMB/Unraid-DVB/raw/master/files/patchutils-0.3.4-x86_64-2.tgz
wget -nc https://github.com/CHBMB/Unraid-DVB/raw/master/files/Proc-ProcessTable-0.53-x86_64-1.tgz

##Download Unraid
cd $D
if [ -e $D/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip]; then
 unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid
else
  wget -nc http://dnld.lime-technology.com/next/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip
  unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid
fi

##Unount bzfirmware and make rw
cp -r /lib/firmware /tmp
umount -l /lib/firmware/
rm -rf  /lib/firmware
mv -f  /tmp/firmware /lib

##libreelec Mediabuild
cd $D
mkdir libreelec-drivers
cd libreelec-drivers
wget -nc https://github.com/LibreELEC/dvb-firmware/archive/$LE.tar.gz
tar xvf $LE.tar.gz

#Copy firmware to /lib/firmware
rsync -av $D/libreelec-drivers/dvb-firmware-$LE/firmware/ /lib/firmware/

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"LibreELEC\" > /lib/firmware/unraid-media
echo driver=\"$LE\" >> /lib/firmware/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/libreelec/
cp /lib/firmware/unraid-media $D/$VERSION/libreelec/

##Make new bzmodules and bzfirmware
mksquashfs /lib/firmware $D/$VERSION/libreelec/bzfirmware -noappend
cp $D/unraid/bzmodules $D/$VERSION/libreelec/bzmodules
