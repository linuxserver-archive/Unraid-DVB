#!/bin/bash

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"

#ls.sh
. /boot/ls.sh

lftp -u $USER,$PASS -e "set ftp:ssl-allow no; mirror -R $D/$VERSION /unraid-dvb/ ;quit" ftp.linuxserver.io
