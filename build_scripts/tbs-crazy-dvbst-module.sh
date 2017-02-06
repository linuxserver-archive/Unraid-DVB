###Deprecated Repo No Longer Exists

#!/bin/bash

###Run kernel_compile.sh prior to running a module###

##Pull variables from github 
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Remove any files remaining in /lib/modules/ & /lib/firmware/
cd $D
find /lib/modules/$(uname -r) -type f -exec rm -rf {} \;
find /lib/firmware -type f -exec rm -rf {} \;

#Restore default /lib/modules/ & /lib/firmware/
rsync -av $D/lib/modules/$(uname -r)/ /lib/modules/$(uname -r)/
rsync -av $D/lib/firmware/ /lib/firmware/

#Create bzroot-tbs files from master
rsync -avr $D/bzroot-master-$VERSION/ $D/bzroot-tbs-crazy-dvbst

##Crazy Cat DVB-ST built from LE script
cd $D
wget -nc https://raw.githubusercontent.com/LibreELEC/LibreELEC.tv/master/tools/mkpkg/mkpkg_media_build
chmod +x mkpkg_media_build
mkpkg_media_build

##Unpack and build from LE package
GIT_REV="$(find media_build-*.tar.xz | cut -c 13-22)"
tar xvf media_build-"$GIT_REV".tar.xz
cd media_build-"$GIT_REV"
./build
make install

#Copy firmware to bzroot
find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot-tbs-crazy-dvbst/ \;
find /lib/firmware/ -type f -exec cp -r --parents '{}' $D/bzroot-tbs-crazy-dvbst/ \;

#Create /etc/unraid-media to identify type of mediabuild and copy to bzroot
echo base=\"TBS \(CrazyCat\) DVB-S\(2\) \& DVB-T\(2\)\" > $D/bzroot-tbs-crazy-dvbst/etc/unraid-media
echo driver=\"$GIT_REV\" >> $D/bzroot-tbs-crazy-dvbst/etc/unraid-media

#Copy /etc/unraid-media to identify type of mediabuild to destination folder
mkdir -p $D/$VERSION/tbs-crazy-dvbst/
cp $D/bzroot-tbs-crazy-dvbst/etc/unraid-media $D/$VERSION/tbs-crazy-dvbst/

#Package Up bzroot
cd $D/bzroot-tbs-crazy-dvbst
find . | cpio -o -H newc | xz --format=lzma > $D/$VERSION/tbs-crazy-dvbst/bzroot

#Package Up bzimage
cp -f $D/kernel/arch/x86/boot/bzImage $D/$VERSION/tbs-crazy-dvbst/bzimage

#Copy default bzroot-gui
cp -f $D/unraid/bzroot-gui $D/$VERSION/tbs-crazy-dvbst/bzroot-gui

#MD5 calculation of files
cd $D/$VERSION/tbs-crazy-dvbst/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5
md5sum bzroot-gui > bzroot-gui.md5

#Return to original directory
cd $D
