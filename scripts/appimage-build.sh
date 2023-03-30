#!/bin/bash

# to tun zbrush 2019, we need this!
# ./start.sh winetricks corefonts mfc42 vcrun6 vcrun2008 vcrun2010 vcrun2013 comctl3


CD=$(dirname $(readlink -f $0))
# APP=$(basename $CD)
APP=$(cat $1/AppRun  | grep '^APP=' | awk -F'=' '{print $2}')
folder=$1
ls -l $1/
ARCH=X86_64 appimagetool $folder $APP.appimage
