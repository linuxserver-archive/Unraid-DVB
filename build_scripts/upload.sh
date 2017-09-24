#!/bin/bash

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"


scp -i /etc/ssh/files.linuxserver.io -r $D/$VERSION/ lsio@mirror.linuxserver.io:/mnt/forum-block/letsencrypt/www/mirror/unraid-dvb-rc/
