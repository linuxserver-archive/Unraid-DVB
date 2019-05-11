#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Pull scripts from Github

wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/master/build_scripts/kernel-compile-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/master/build_scripts/libreelec-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/master/build_scripts/dd-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/master/build_scripts/tbs-os-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/master/build_scripts/tbs-crazy-dvbst-module.sh
wget https://raw.githubusercontent.com/linuxserver/Unraid-DVB/master/build_scripts/upload.sh


##Make executable
chmod +x *.sh

##Run builds
$D/kernel-compile-module.sh && \
$D/libreelec-module.sh && \
$D/tbs-os-module.sh && \
$D/tbs-crazy-dvbst-module.sh && \
$D/dd-module.sh && \
$D/upload.sh
