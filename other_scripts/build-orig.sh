#!/bin/bash
D="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"

BZROOT="/boot/bzroot" 

URLS="
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/gcc-4.8.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/gcc-g++-4.8.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/patches/packages/glibc-2.17-x86_64-10_slack14.1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/binutils-2.23.52.0.1-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/make-3.82-x86_64-4.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/a/cxxlibs-6.0.18-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/perl-5.18.1-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/a/patch-2.7-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/mpfr-3.1.2-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/ap/bc-1.06.95-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/patches/packages/linux-3.10.17-2/kernel-headers-3.10.17-x86-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/libmpc-0.8.2-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/ncurses-5.9-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/a/cpio-2.11-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/pkg-config-0.25-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/autoconf-2.69-noarch-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/automake-1.11.5-noarch-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/l/libmpc-0.8.2-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/ap/sqlite-3.7.17-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/pkg-config-0.25-x86_64-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/automake-1.11.5-noarch-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/autoconf-2.69-noarch-1.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/libtool-2.4.2-x86_64-2.txz
http://mirrors.slackware.com/slackware/slackware64-14.1/slackware64/d/m4-1.4.17-x86_64-1.txz
"

ask() {
    # http://djm.me/ask
    while true; do
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question
        echo ''
        read -p "$1 [$prompt] " REPLY

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

## MODULES ##
do_install_modules(){
  [ ! -d "$D/packages" ] && mkdir $D/packages
  OLD_IFS="$IFS";IFS=$'\n';
  for url in $URLS; do
    PKGPATH=${D}/packages/$(basename $url)
    [ ! -e "${PKGPATH}" ] && wget --no-check-certificate $url -O "${PKGPATH}"
    [[ "${PKGPATH}" == *.txz ]] && installpkg "${PKGPATH}"
  done
  IFS="$OLD_IFS";
}

## KERNEL
do_extract_kernel(){
  [[ $(uname -r) =~ ([0-9.]*) ]] &&  KERNEL=${BASH_REMATCH[1]} || return 1
  LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL}.tar.xz"

  rm -rf $D/kernel; mkdir $D/kernel

  [[ ! -f $D/linux-${KERNEL}.tar.xz ]] && wget $LINK -O $D/linux-${KERNEL}.tar.xz
  
  tar -C $D/kernel --strip-components=1 -Jxf $D/linux-${KERNEL}.tar.xz

  rsync -av /usr/src/linux-$(uname -r)/ $D/kernel/

  cd $D/kernel
  for p in $(find . -type f -iname "*.patch"); do
    patch -p 1 < $p
  done

  make oldconfig
}

do_make_menuconfig(){
  cd $D/kernel
  make menuconfig
}

do_compile_kernel(){
  cd $D/kernel
  make -j $(cat /proc/cpuinfo | grep -m 1 -Po "cpu cores.*?\K\d")
}

do_install_kernel_modules () {
  cd $D/kernel
  make all modules_install install
}

do_copy_bzimage(){
  cp -f $D/kernel/arch/x86/boot/bzImage /boot/bzimage-new
}

do_copy_bzroot(){
  cp -f $D/bzroot-new /boot/bzroot-new
}


do_extract_bzroot(){
  rm -rf $D/bzroot; mkdir $D/bzroot; cd $D/bzroot
  xzcat ${BZROOT} | cpio -i -d -H newc --no-absolute-filenames
}

do_copy_modules(){
  cd $D/kernel/
  make modules_install
  mkdir -p $D/bzroot
  find /lib/modules/$(uname -r) -type f -exec cp -r --parents '{}' $D/bzroot/ \;
}

do_install_packages() {
for package in $(find /boot/extra/ -iname "*.t*z"); do
  ROOT=$D/bzroot installpkg $package; 
done
}

do_compress_bzroot(){
  cd $D/bzroot
  find . | cpio -o -H newc | xz --format=lzma > "${D}/bzroot-new"
}

do_cleanup(){
  rm -rf $D/bzroot $D/kernel $D/packages $D/linux-*.tar.xz
}

if ask "1) Do you want to clean directories?" N ; then do_cleanup; fi

if ask "2) Do you want to install build dependencies?" $([[ -f /usr/bin/make ]] && echo N||echo Y;) ; then do_install_modules; fi

if ask "3) Do you want to download and extract the Linux kernel?" $([[ -f $D/kernel/.config ]] && echo N||echo Y;) ;then do_extract_kernel;fi

if [[ -f $D/kernel/.config ]]; then
  if ask "3.1) Do you want to run Menu Config ?" N ;then do_make_menuconfig; fi
  if ask "3.2) Do you want to compile the Linux kernel?" N ;then do_compile_kernel; fi
  if ask "3.3) Do you want to install Linux kernel modules?" N ;then do_install_kernel_modules; fi
fi

if ask "4) Do you want to extract BZROOT" $([[ -L $D/bzroot/init ]] && echo N||echo Y;); then do_extract_bzroot ; fi

if [[ -L $D/bzroot/init ]]; then
  if [[ -f $D/kernel/.config ]]; then
    if ask "4.1) Do you want to slipstream compiled modules?" N ;then do_copy_modules; fi
  fi
  if ask "4.2) Do you want to install packages from /boot/extra ?" N ;then do_install_packages; fi
  if ask "4.3) Do you want to compress bzroot?" N ;then do_compress_bzroot; fi
fi

if [[ -f ${D}/bzroot-new ]]; then
  if ask "5) Do you want to copy ${D}/bzroot-new to ${BZROOT}-new?" N ;then do_copy_bzroot; fi
fi

if [[ -f $D/kernel/arch/x86/boot/bzImage ]]; then
  if ask "6) Do you want to copy bzimage to /boot/bzimage-new?" N ;then do_copy_bzimage; fi
fi
