#!/bin/bash

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"

docker start s3cmd
docker exec s3cmd s3cmd sync $D/$VERSION s3://lsio/unraid-dvb/ --acl-public
docker stop s3cmd