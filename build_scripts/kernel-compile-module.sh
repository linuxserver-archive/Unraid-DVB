#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Install packages
[ ! -d "$D/packages" ] && mkdir $D/packages
  wget -nc -P $D/packages -i $D/URLS_CURRENT
  wget -nc -P $D/packages https://github.com/CHBMB/Unraid-DVB/raw/master/files/patchutils-0.3.4-x86_64-2.tgz
  wget -nc -P $D/packages https://github.com/CHBMB/Unraid-DVB/raw/master/files/Proc-ProcessTable-0.53-x86_64-1.tgz
  installpkg $D/packages/*.*

#Change to current directory
cd $D

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

##Download and Install Kernel
[[ $(uname -r) =~ ([0-9.]*) ]] &&  KERNEL=${BASH_REMATCH[1]} || return 1
  LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL}.tar.xz"
  rm -rf $D/kernel; mkdir $D/kernel
  [[ ! -f $D/linux-${KERNEL}.tar.xz ]] && wget $LINK -O $D/linux-${KERNEL}.tar.xz

  tar -C $D/kernel --strip-components=1 -Jxf $D/linux-${KERNEL}.tar.xz
  rsync -av /usr/src/linux-$(uname -r)/ $D/kernel/
  cd $D/kernel
  for p in $(find . -type f -iname "*.patch"); do patch -N -p 1 < $p
  done
  make oldconfig

##Make menuconfig
cd $D
wget https://files.linuxserver.io/unraid-dvb-rc/$VERSION/stock/.config
cd $D/kernel
if [ -e $D/.config ]; then
   rm -f .config
   rsync $D/.config $D/kernel/.config
else
   make menuconfig
fi

##Compile Kernel
cd $D/kernel
make -j $(cat /proc/cpuinfo | grep -m 1 -Po "cpu cores.*?\K\d")

##Install Kernel Modules
cd $D/kernel
make all modules_install install

##Download Unraid
cd $D
if [ -e $D/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip]; then
 unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid
else
  wget -nc http://dnld.lime-technology.com/next/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip
  unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid
fi

##Copy default Unraid bz files to folder prior to uploading
mkdir -p $D/$VERSION/stock/
cp -f $D/unraid/bzimage $D/$VERSION/stock/
cp -f $D/unraid/bzroot $D/$VERSION/stock/
cp -f $D/unraid/bzroot-gui $D/$VERSION/stock/
cp -f $D/unraid/bzmodules $D/$VERSION/stock/
cp -f $D/unraid/bzfirmware $D/$VERSION/stock/
cp -f $D/kernel/.config $D/$VERSION/stock/

##Calculate md5 on stock files
cd $D/$VERSION/stock/
md5sum bzimage > bzimage.md5
md5sum bzroot > bzroot.md5
md5sum bzroot-gui > bzroot-gui.md5
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum .config > .config.md5

##Make new bzmodules and bzfirmware - overwriting existing
mksquashfs /lib/modules /boot/bzmodules -noappend
mksquashfs /lib/firmware /boot/bzfirmware -noappend

##Make backup of /lib/firmware & /lib/modules
mkdir -p $D/backup/modules
cp -r /lib/modules/ $D/backup/
mkdir -p $D/backup/firmware
cp -r /lib/firmware/ $D/backup/

##Copy new bzfirmware & bzmodule to stock
cp -f /boot/bzmodules $D/$VERSION/stock/bzmodules-new
cp -f /boot/bzfirmware $D/$VERSION/stock/bzfirmware-new

##Calculate md5 on new bzfirmware & bzmodules
cd $D/$VERSION/stock/
md5sum bzmodules-new > bzmodules-new.md5
md5sum bzfirmware-new > bzfirmware-new.md5

##Return to original directory
cd $D
