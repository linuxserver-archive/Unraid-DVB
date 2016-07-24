#!/bin/bash

##Current TBS Drivers See http://www.tbsdtv.com/download/
TBS="160405"

# current LibreELEC Release - See https://github.com/LibreELEC/dvb-firmware/releases
LE="1.0.0"

# current OpenELEC Release - See https://github.com/CvH/dvb-firmware/releases
OE="1.11"

# current Digital Devices Github release - See https://github.com/DigitalDevices/dddvb/releases
DD="0.9.23"

# current Date (DDExp Version)
DATE=$(date +'%d%m%y')

##Current Unraid Version
VERSION="$((grep -o '".*"' /etc/unraid-version | sed 's/"//g') | sed 's/\./\-/g')"

##Working directory
D="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"

##Packages required 
URLS="
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/a/cpio-2.11-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/a/cxxlibs-6.0.18-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/a/patch-2.7-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/ap/bc-1.06.95-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/ap/sqlite-3.7.17-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/autoconf-2.69-noarch-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/automake-1.11.5-noarch-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/binutils-2.23.52.0.1-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/gcc-4.8.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/gcc-g++-4.8.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/patches/packages/linux-3.10.17-2/kernel-headers-3.10.17-x86-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/libtool-2.4.2-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/m4-1.4.17-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/make-3.82-x86_64-4.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/mercurial-2.7.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/perl-5.18.1-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/pkg-config-0.25-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/patches/packages/glibc-2.17-x86_64-11_slack14.1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/libmpc-0.8.2-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/mpfr-3.1.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/ncurses-5.9-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/n/lftp-4.4.9-x86_64-1.txz
https://raw.githubusercontent.com/eschultz/unraid6-nerdpack/master/packages/python-2.7.9-x86_64-1.txz
"
