#!/bin/bash

set -ea

: "${BRANCH:=master}"
: "${DEPENDENCY_BRANCH:=master}"

##Pull variables from github
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/${DEPENDENCY_BRANCH}/build_scripts/variables.sh
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/${DEPENDENCY_BRANCH}/build_scripts/dvb-variables.sh

##Pull scripts from Github

wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/${BRANCH}/build_scripts/kernel-compile-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/${BRANCH}/build_scripts/libreelec-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/${BRANCH}/build_scripts/dd-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/${BRANCH}/build_scripts/tbs-os-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/${BRANCH}/build_scripts/tbs-crazy-dvbst-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/${BRANCH}/build_scripts/upload.sh


#Run modules
chmod +x *.sh
source ./variables.sh

if [[ -z "$D" ]]; then
    echo "Must provide D in environment" 1>&2
    exit 1
fi

source ${D}/dvb-variables.sh

$D/kernel-compile-module.sh && \
$D/libreelec-module.sh && \
$D/tbs-os-module.sh && \
$D/tbs-crazy-dvbst-module.sh && \
$D/dd-module.sh && \
$D/upload.sh
