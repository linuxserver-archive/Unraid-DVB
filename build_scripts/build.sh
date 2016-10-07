#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

$D/kernel-compile-module.sh && \
$D/libreelec-module.sh && \
$D/tbs-official-dvbst-module.sh && \
$D/tbs-official-dvbc-module.sh && \
$D/tbs-crazy-dvbst-module.sh && \
$D/dd-module.sh
$D/ftp.sh

rm -rf $D/bzroot-dd $D/bzroot-libreelec $D/bzroot-tbs-* $D/kernel $D/lib $D/libreelec-drivers $D/packages $D/tbs-drivers-* $D/unraid $D/FILE_LIST $D/linux-*.tar.xz $D/unRAIDServer-*.zip $D/URLS $D/variables.sh
