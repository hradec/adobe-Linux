#!/bin/bash

if [ "$1" == "" ] ; then
    exit -1
fi

if [ "$$(ping -c 3 -W 2 adobe.local | grep ' 0%')" == "" ] ; then
    echo -e "\n\nThe adobe.local vm that contains adobe applications already installed is not online!!\nCan't get Photoshop SUBVERSION!!"
    exit -1
fi

lines=$(ssh game@adobe.local "cat /cygdrive/c/Adobe/Adobe\ Photoshop\ $1/AMT/application.xml")
echo "$lines" | sed "s/[>,<]/\n/g" | grep ProductVersion -A1 | tail -1
