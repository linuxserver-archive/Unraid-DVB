##Pull variables from github 
wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/files/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Pull slackware64-current FILE_LIST to get packages
wget -nc http://mirrors.slackware.com/slackware/slackware64-current/slackware64/FILE_LIST

#Change to current directory
cd $D

##Install pkg modules
[ ! -d "$D/packages" ] && mkdir $D/packages
  wget -nc -P $D/packages -i $D/URLS
  installpkg $D/packages/*.txz