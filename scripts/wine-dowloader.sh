#!/bin/bash

_CD=$(dirname $(readlink -f $0))
CD=$(pwd)


while getopts hlv: option ; do
    case "${option}"
    in
        h) export HELP=1;;
        l) export LIST=1;;
        v) ver="${OPTARG}";;
    esac
done

if [ "$LIST" != "" ] ; then
	version_list=$(curl -L 'https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-amd64' | grep '.deb"' | awk -F'<a href="' '{print $2}' | awk -F'">' '{print $1}' | grep devel_ | grep -v winehq  | while read p ; do echo -e  "$(echo $p | sed 's/~/_/g' | awk -F'_' '{print $2}')\t$p" ; done | sort)
	echo "$version_list"
	exit -1
#	v=$(echo "$version_list" | tail -1 | awk '{print $1}')
fi
v=$ver
if [ "$v" == "" ] || [ "$HELP" != "" ] ; then
	echo "$(basename $0) - downloads wine versions from WineHQ Ubuntu 18.04 depot"
	echo ""
	echo "		-h	show this help"
	echo "		-l	list the available versions for download"
	echo "		-v	specify the version to download"
	echo ""
	echo "The version version will be installed in a 'wine' folder at the same path this script"
	echo "is located - $CD/wine/<version>"
	echo ""
	echo ""
	exit -1
fi

echo "downloading version $v..."


mkdir -p $CD/wine/download/temp
cd $CD/wine/download/

# wine-devel-i386 (= 8.4~bionic-1), wine-devel-amd64 (= 8.4~bionic-1)
curl -L -O "https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-amd64/wine-devel_$v~bionic-1_amd64.deb"
curl -L -O "https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-devel-i386_$v~bionic-1_i386.deb"
curl -L -O "https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-amd64/wine-devel-amd64_$v~bionic-1_amd64.deb"

cd $CD/wine/download/temp

ar x ../wine-devel_$v~bionic-1_amd64.deb
tar xf data.tar.*

ar x ../wine-devel-i386_$v~bionic-1_i386.deb
tar xf data.tar.*

ar x ../wine-devel-amd64_$v~bionic-1_amd64.deb
tar xf data.tar.*

mv opt/wine-devel $CD/wine/$v
unlink $CD/wine/current
ln -s $v $CD/wine/current

ls -l $CD/wine/

cd ..
rm -rf $CD/wine-download/temp
