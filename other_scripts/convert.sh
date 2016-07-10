#!/bin/bash

##Working directory
D="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
 
##Extract bzroot
mkdir $D/extract; cd $D/extract
xzcat $D/bzroot | cpio -i -d -H newc --no-absolute-filenames

##Remove old bzroot and md5
rm $D/bzroot
rm $D/bzroot.md5

##Create /etc/unraid-media to identify type of mediabuild
#echo base=\"$VERSION\" > $D/extract/etc/unraid-media
#echo driver=\"$DRIVER\" >> $D/extract/etc/unraid-media
#cp $D/extract/etc/unraid-media $D/unraid-media

#Replace OpenElec with LibreELEC
sed -i s/OpenElec/LibreELEC/g $D/extract/etc/unraid-media
sed -i s/OpenElec/LibreELEC/g $D/unraid-media

##Package Up Files
cd $D/extract
find . | cpio -o -H newc | xz --format=lzma > "${D}/bzroot"

##Create md5 files
cd $D/
md5sum bzroot > bzroot.md5

##Remove extract
rm -rf $D/extract

##Mark folder as being done
echo base=\"done\" > $D/done
