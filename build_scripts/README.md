![https://linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)

## Uploading

Set up an s3cmd docker container with the following:

```
docker create \
  --name=s3cmd \
  -v /mnt/disk1/appdata/s3cmd:/config \
  -v /mnt:/mnt:ro \
  -e TZ=Europe/London \
  aptalca/docker-s3cmd
```

Initial setup: 
`docker exec -it s3cmd s3cmd --configure`

* Enter the access key and the secret key
* Set region to `UK`
* Endpoint will be `ams3.digitaloceanspaces.com`
* DNS-based bucket will be `%(bucket)s.ams3.digitaloceanspaces.com`
* Rest can be left as default (hit enter)
* It should test connection and if successful, hit yes to save config
* The config file will be in the `/config` folder

Leave the container running while the build scripts run

## NVIDIA Driver Install (Work In Progress)

### *First method*

* From a base Unraid install and in a dedicated cache directory run this.

It will compile the kernel and the nvidia kernel modules, then stage the driver dev with all the sources.  Any new variables required will need to be added to [nvidia-variables.sh](https://github.com/CHBMB/Unraid-DVB/blob/master/build_scripts/nvidia-variables.sh)
```
#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Get required scripts
wget https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/nvidia-kernel-compile-module.sh
wget https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/nvidia-kernel.sh
wget https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/nvidia-driver.sh
chmod +x $D/*.sh
$D/nvidia-kernel-compile-module.sh && \
$D/nvidia-kernel.sh && \
$D/nvidia-driver.sh
```

### *Second Method (Preferred)*

Use the precompiled NVIDIA Kernel Modules build and in a dedicated cache directory run this.  Once this is run you will have all the NVIDIA sources for a driver install.  Any new variables required will need to be added to [nvidia-variables.sh](https://github.com/CHBMB/Unraid-DVB/blob/master/build_scripts/nvidia-variables.sh)

```
#!/bin/bash

##Pull variables from github
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Get required scripts
wget https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/nvidia-kernel-compile-module.sh
wget https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/nvidia-driver.sh
chmod +x $D/*.sh
$D/nvidia-kernel-compile-module.sh && \
$D/nvidia-driver.sh
```
