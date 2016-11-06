![https://linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)

#.config

The .config in this folder will always be based on the current stable or beta release of UnRAID.  Others are as named.

#patch-utils

wget http://cyberelk.net/tim/data/patchutils/stable/patchutils-0.3.4.tar.xz
tar xvf patchutils-0.3.4.tar.xz
cd patchutils-0.3.4
./configure
make
make install
