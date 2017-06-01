#!/bin/bash
##This will create a base Unraid bzmodules & bzfirmware - not required after LT release.

##Clean up working directory
rm -rf $D/bzroot-dd $D/bzroot-libreelec $D/bzroot-tbs-* $D/kernel $D/libreelec-drivers $D/packages $D/tbs-drivers-* $D/unraid $D/FILE_LIST $D/linux-*.tar.xz $D/unRAIDServer-*.zip $D/URLS $D/variables.sh

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

#Download patchutils & Proc-ProcessTable
mkdir $D/packages
cd $D/packages
wget -nc https://github.com/CHBMB/Unraid-DVB/raw/master/files/patchutils-0.3.4-x86_64-2.tgz
wget -nc https://github.com/CHBMB/Unraid-DVB/raw/master/files/Proc-ProcessTable-0.53-x86_64-1.tgz

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

##Install packages
[ ! -d "$D/packages" ] && mkdir $D/packages
  wget -nc -P $D/packages -i $D/URLS_CURRENT
  installpkg $D/packages/*.*
  
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
##Remove this once released
wget https://files.linuxserver.io/unraid-dvb-old-builds/$VERSION/stock/.config
##Unhash this once released
#wget https://files.linuxserver.io/unraid-dvb/$VERSION/stock/.config
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

##Make new bzmodules and bzfirmware
mkdir -p $D/$VERSION/stock/
mksquashfs /lib/modules $D/$VERSION/stock/bzmodules -noappend
mksquashfs /lib/firmware $D/$VERSION/stock/bzfirmware -noappend

##Copy default Unraid bz files to folder prior to uploading
cp -f $D/unraid/bzimage $D/$VERSION/stock/
cp -f $D/unraid/bzroot $D/$VERSION/stock/
cp -f $D/unraid/bzroot-gui $D/$VERSION/stock/
cp -f $D/kernel/.config $D/$VERSION/stock/

##Calculate md5 on stock files
cd $D/$VERSION/stock/
md5sum bzimage > bzimage.md5
md5sum bzroot > bzroot.md5
md5sum bzroot-gui > bzroot-gui.md5
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum .config > .config.md5

#Return to original directory
cd $D
