#!/bin/bash

##Mediabuild version
VERSION="OpenElec"

##Driver version
DRIVER="1.8"

##Working directory
D="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
 
##Extract bzroot
mkdir $D/extract; cd $D/extract
xzcat $D/bzroot | cpio -i -d -H newc --no-absolute-filenames

##Remove old bzroot
rm $D/bzroot

##Create /etc/unraid-media to identify type of mediabuild
echo base=\"$VERSION\" > $D/extract/etc/unraid-media
echo driver=\"$DRIVER\" >> $D/extract/etc/unraid-media
cp $D/extract/etc/unraid-media $D/unraid-media

##Package Up Files
cd $D/extract
find . | cpio -o -H newc | xz --format=lzma > "${D}/bzroot"

##Create md5 files
cd $D/
md5sum bzroot > bzroot.md5
md5sum bzimage > bzimage.md5

##Remove extract
rm -rf $D/extract
