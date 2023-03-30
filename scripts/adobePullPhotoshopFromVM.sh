#!/bin/bash

CD=$(dirname $(readlink -f $0))
[ "$1" == "" ] && echo "specify the wineprefix to pull program files to and the version of photoshop!!" && exit -1

# pull data from windows vm, if online!
#source $CD/run.sh
cd $CD
install=$(readlink -f $1)
if [ "$(ping -c 3 -W 2 adobe.local | grep ' 0%')" != "" ] ; then
    rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files/Adobe'                   $install/drive_c/Program\ Files/
    rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files/Common\ Files'           $install/drive_c/Program\ Files/
    rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files\ \(x86\)/Adobe'          $install/drive_c/Program\ Files\ \(x86\)/
    rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files\ \(x86\)/Common\ Files'  $install/drive_c/Program\ Files\ \(x86\)/
    rsync -avpP --no-perms --no-owner --no-group --delete --delete-excluded game@adobe.local:"'/cygdrive/c/Adobe/Adobe\ Photoshop\ $2/'"          $CD/Adobe\ Photoshop\ $2/
    # rsync -avpP --no-perms --no-owner --no-group --delete --delete-excluded game@adobe.local:'/cygdrive/c/Adobe/Adobe\ Photoshop\ 2023/'          $CD/Adobe\ Photoshop\ 2023/
fi
