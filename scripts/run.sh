#!/bin/bash

_CD=$(dirname $(readlink -f $0))

# set the wine version by creating a current link to the version in
# the wine folder
v=wine/current
CD=$(pwd)
if [ ! -e $CD/$v ] ; then
	CD=$_CD
fi
if [ ! -e $CD/$v ] ; then
	echo "Error: folder $CD/$v not found!!"
	exit -1
fi
echo $CD/$v

export PATH=$CD/$v/bin:$PATH
export LD_LIBRARY_PATH=$CD/$v/lib64/wine/x86_64-windows/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$CD/$v/lib64/wine/x86_64-unix/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$CD/$v/lib/wine/i386-windows/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$CD/$v/lib/wine/i386-unix/:$LD_LIBRARY_PATH

# we only set wineprefix to default if no wineprefix is set before!
if [ "$WINEPREFIX" == "" ] ; then
	export WINEPREFIX=$CD/install/
	if [ -e $CD/install/Adobe-Photoshop ] ; then
		export WINEPREFIX=$CD/install/Adobe-Photoshop/
	fi
fi

export SCR_PATH="pspath"
export CACHE_PATH="pscache"
export RESOURCES_PATH="$SCR_PATH/resources"
export WINE_PREFIX="$SCR_PATH/prefix"
export FILE_PATH=$(winepath -w "$1")
# export DXVK_LOG_PATH=$WINEPREFIX
# export DXVK_STATE_CACHE_PATH=$WINEPREFIX

export __GL_THREADED_OPTIMIZATION=1
export WINEDEBUG=-all
export LC_ALL=C

#disable wine-gecko
#export WINEDLLOVERRIDES="mscoree,mshtml="

if [ 1 -gt 1 ] ; then
	curl -L https://raw.githubusercontent.com/scottyhardy/docker-wine/master/docker-wine > docker-wine
	chmod +x docker-wine

	$CD/docker-wine  \
		--volume="$(pwd):$(pwd)" \
		--env="WINEPREFIX=$CD/install/Adobe-Photoshop/" \
		--as-me --force-owner \
		wine "$@"
else
	"$@"
fi
