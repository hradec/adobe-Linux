#!/bin/bash

CD=$(dirname $(readlink -f $0))
[ "$1" == "" ] && echo "specify the wineprefix to pull program files to!!" && exit -1

# pull data from windows vm, if online!
#source $CD/run.sh
cd $CD
install=$(readlink -f $1)
if [ "$(ping -c 3 -W 2 adobe.local | grep ' 0%')" != "" ] ; then
    rsync -avpP --no-perms --no-owner --no-group --delete --delete-excluded game@adobe.local:'/cygdrive/c/Adobe/Adobe\ Substance\ 3D\ Painter/'   $CD/Adobe\ Substance\ 3D\ Painter/
fi
