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

##Unmount bzmodules and make rw
cp -r /lib/modules /tmp
umount -l /lib/modules/
rm -rf  /lib/modules
mv -f  /tmp/modules /lib

##Unount bzfirmware and make rw
cp -r /lib/firmware /tmp
umount -l /lib/firmware/
rm -rf  /lib/firmware
mv -f  /tmp/firmware /lib

##Open Source DVB-ST build
cd $D
git clone https://github.com/tbsdtv/media_build.git
git clone --depth=1 https://github.com/tbsdtv/linux_media.git -b latest ./media
cd media_build
make dir DIR=../media
make distclean
make
make install

##Firmware from Current TBS Closed Source Drivers
mkdir -p $D/tbs-os-firmware/
cd $D/tbs-os-firmware/
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/

#Create /lib/firmware/unraid-media to identify type of mediabuild
echo base=\"TBS \(Open Source\) \& LibreELEC ATSC-C, DVB-C, DVB-S\(2\) \& DVB-T\(2\)\" > /lib/firmware/unraid-media
echo driver=\"$DATE\" >> /lib/firmware/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-os/
cp /lib/firmware/unraid-media $D/$VERSION/tbs-os/

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/stock/
mksquashfs /lib/modules $D/$VERSION/tbs-os/bzmodules -noappend
mksquashfs /lib/firmware $D/$VERSION/tbs-os/bzfirmware -noappend

#MD5 calculation of files
cd $D/$VERSION/tbs-os/
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5

#Return to original directory
cd $D

##Restore /lib/modules/ & /lib/firmware/
rm -rf  /lib/modules
rm -rf  /lib/firmware
mkdir /lib/modules
mkdir /lib/firmware
mount /unraid/bzmodules /lib/firmware -t squashfs -o loop
mount /unraid/bzfirmware /lib/firmware -t squashfs -o loop
