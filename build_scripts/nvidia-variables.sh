#!/bin/bash

# set our package list
slack_package_current=(\
atk \
cairo \
cairomm \
dbus \
expat \
fontconfig \
freetype \
fribidi \
glib2 \
gdk-pixbuf2 \
gtk+2 \
gtk+3 \
gtkmm2 \
gtkmm3 \
harfbuzz \
libdrm \
libpciaccess \
libpng \
libpthread-stubs \
libvdpau \
libxcb \
libxshmfence \
libX11 \
libXau \
libXdamage \
libXdmcp \
libXext \
libXfixes \
libXrandr \
libXrender \
libXv \
libXvMC \
libXxf86vm \
mesa \
opencl-headers \
pango \
pangomm \
pcre \
pcre2 \
pixman \
xorgproto \
xcb-proto \
xrandr \
zlib \
)

# current Date (DDExp & TBS OS Version)
DATE=$(date +'%d%m%y')

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# clean up old files if they exist
[[ -f "$D"/FILE_LIST_CURRENT ]] && rm "$D"/FILE_LIST_CURRENT
[[ -f "$D"/URLS_CURRENT ]] && rm "$D"/URLS_CURRENT

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"

# get slackware64-current FILE_LIST
wget -nc http://mirrors.slackware.com/slackware/slackware64-current/slackware64/FILE_LIST -O $D/FILE_LIST_CURRENT

slack_package_current_urlbase="http://mirrors.slackware.com/slackware/slackware64-current/slackware64"

for i in "${slack_package_current[@]}"
do
package_locations_current=$(grep "/$i-[[:digit:]].*.txz$" FILE_LIST_CURRENT | cut -b 53-9001)
echo "$slack_package_current_urlbase""$package_locations_current" >> "$D"/URLS_CURRENT
done
