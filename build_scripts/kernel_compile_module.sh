#!/bin/bash

##Pull variables from github 
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/V6.0.0-V6.1.9/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Remove old folders
rm -rf $D/bzroot-ddexp $D/bzroot-master-* $D/bzroot-openelec $D/bzroot-tbs  $D/kernel $D/lib $D/media_build_experimental $D/openelec-drivers $D/tbs-drivers $D/unraid $D/.config $D/linux-*.tar.xz  $D/unRAIDServer-*.zip 

#Change to current directory
cd $D

##Install pkg modules
[ ! -d "$D/packages" ] && mkdir $D/packages
  OLD_IFS="$IFS";IFS=$'\n';
  for url in $URLS; do
    PKGPATH=${D}/packages/$(basename $url)
    [ ! -e "${PKGPATH}" ] && wget --no-check-certificate $url -O "${PKGPATH}"
    [[ "${PKGPATH}" == *.txz ]] && installpkg "${PKGPATH}"
  done
  IFS="$OLD_IFS";
  
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
#cd $D/kernel
#make menuconfig
 
##Use preconfigured .config rather than going through make menuconfig
cd $D
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/V6.0.0-V6.1.9/files/.config
cd $D/kernel
rm -f .config
rsync $D/.config $D/kernel/.config

##Compile Kernel
cd $D/kernel
make -j $(cat /proc/cpuinfo | grep -m 1 -Po "cpu cores.*?\K\d")

##Install Kernel Modules
cd $D/kernel
make all modules_install install

##Download Unraid Comment/Uncomment for Beta/Stable
cd $D
wget -nc http://dnld.lime-technology.com/stable/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip
#wget -nc http://dnld.lime-technology.com/beta/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip
unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid

##Extract bzroot
rm -rf $D/bzroot-master-$VERSION; mkdir $D/bzroot-master-$VERSION; cd $D/bzroot-master-$VERSION
xzcat $D/unraid/bzroot | cpio -i -d -H newc --no-absolute-filenames

##Copy default Mediabuild Kernel Modules to bzroot
cd $D/kernel/
make modules_install
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-master-$VERSION/ \;

##Backup /lib/modules/ & /lib/firmware/
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/ \;
find /lib/firmware -type f -exec cp -r --parents '{}' $D/ \;

##Copy default Unraid bz files to folder prior to uploading
mkdir -p $D/$VERSION/stock/
cp -f $D/unraid/bzimage $D/$VERSION/stock/
cp -f $D/unraid/bzroot $D/$VERSION/stock/

##Calculate md5 on stock files
cd $D/$VERSION/stock/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5

#Return to original directory
cd $D
