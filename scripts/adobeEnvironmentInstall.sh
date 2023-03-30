#!/bin/bash

CD=$(dirname $(readlink -f $0))

install=$(readlink -f $1)
shift

source $CD/run.sh

mkdir -p $install/

if [ "$(cat winetricks 2>/dev/null)" == "" ] ; then
    curl -L  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > winetricks
fi
chmod +x winetricks

WINEPREFIX=$install/ wineboot

rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "10" >> $install/progress.mimifile

WINEPREFIX=$install/ ./winetricks win10

if [ "$(cat $CD/../payloads/allredist.tar.xz 2>/dev/null)" == "" ] ; then
    curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/PS2022/allredist.tar.xz" > $CD/../payloads/allredist.tar.xz
fi
mkdir -p allredist

rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "20" >> $install/progress.mimifile

tar -xf $CD/../payloads/allredist.tar.xz
# rm -rf allredist.tar.xz

rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "25" >> $install/progress.mimifile

#curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/PS2022/AdobePhotoshop2022.tar.xz" > AdobePhotoshop2022.tar.xz
#curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/PS2022/Adobe.tar.xz" > Adobe.tar.xz
#tar -xf Adobe.tar.xz
#mv Adobe $install//drive_c/Program\ Files\ \(x86\)/Common\ Files
#rm -rf Adobe.tar.xz
#rm -rf Adobe

rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "50" >> $install/progress.mimifile

#tar -xf AdobePhotoshop2022.tar.xz
#rm -rf AdobePhotoshop2022.tar.xz


rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "70" >> $install/progress.mimifile


WINEPREFIX=$install/ ./winetricks -q fontsmooth=rgb gdiplus msxml3 msxml6 atmlib corefonts dxvk win10 vkd3d 2>&1 | tee winetricks.log
rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "80" >> $install/progress.mimifile


# WINEPREFIX=$install/ wine allredist/redist/2010/vcredist_x64.exe /q /norestart
# WINEPREFIX=$install/ wine allredist/redist/2010/vcredist_x86.exe /q /norestart
#
# WINEPREFIX=$install/ wine allredist/redist/2012/vcredist_x86.exe /install /quiet /norestart
# WINEPREFIX=$install/ wine allredist/redist/2012/vcredist_x64.exe /install /quiet /norestart
#
# WINEPREFIX=$install/ wine allredist/redist/2013/vcredist_x86.exe /install /quiet /norestart
# WINEPREFIX=$install/ wine allredist/redist/2013/vcredist_x64.exe /install /quiet /norestart
#
# WINEPREFIX=$install/ wine allredist/redist/2019/VC_redist.x64.exe /install /quiet /norestart
# WINEPREFIX=$install/ wine allredist/redist/2019/VC_redist.x86.exe /install /quiet /norestart

#WINEPREFIX=$install/ wine allredist/MicrosoftEdgeWebView2RuntimeInstallerX86.exe /install /quiet /norestart
#WINEPREFIX=$install/ wine allredist/MicrosoftEdgeWebView2RuntimeInstallerX64.exe /install /quiet /norestart

WINEPREFIX=$install/ ./winetricks -q vcrun2010 vcrun2012 vcrun2013 vcrun2019 vcrun2022 2>&1 | tee -a winetricks.log

# curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/PS2022/wine-tkg-staging-pspatch.tar.xz" > wine-tkg-staging-pspatch.tar.xz
# tar -xf wine-tkg-staging-pspatch.tar.xz
# mv wine-tkg-staging-pspatch/ $install//drive_c/
# rm -rf wine-tkg-staging-pspatch.tar.xz

rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "90" >> $install/progress.mimifile

#WINEPREFIX=$install/ sh allredist/setup_vkd3d_proton.sh install

mkdir -p $install//drive_c/Program\ Files/Adobe
# mv Adobe\ Photoshop\ 2022 $install//drive_c/Program\ Files/Adobe/Adobe\ Photoshop\ 2022

touch $install//drive_c/launcher.sh
echo '#!/usr/bin/env bash' >> $install//drive_c/launcher.sh
echo 'SCR_PATH="pspath"' >> $install//drive_c/launcher.sh
echo 'CACHE_PATH="pscache"' >> $install//drive_c/launcher.sh
echo 'RESOURCES_PATH="$SCR_PATH/resources"' >> $install//drive_c/launcher.sh
echo 'WINE_PREFIX="$SCR_PATH/prefix"' >> $install//drive_c/launcher.sh
echo 'FILE_PATH=$(winepath -w "$install")' >> $install//drive_c/launcher.sh
echo 'export WINEPREFIX="'$install'/"' >> $install//drive_c/launcher.sh
echo 'WINEPREFIX='$install'/ DXVK_LOG_PATH='$install'/ DXVK_STATE_CACHE_PATH='$install'/ '$install'//drive_c/wine-tkg-staging-pspatch/bin/wine64 ' $install'//drive_c/Program\ Files/Adobe/Adobe\ Photoshop\ 2022/photoshop.exe $FILE_PATH' >> $install//drive_c/launcher.sh

chmod +x $install//drive_c/launcher.sh

rm -rf Adobe\ Photoshop\ 2022

WINEPREFIX=$install/ winecfg -v win10


rsync -avpP allredist/photoshop.png ~/.local/share/icons/photoshop.png

if [ "$(cat $CD/../payloads/Adobe_Photoshop_2022_Settings.tar.xz 2>/dev/null)" == "" ] ; then
    curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/PS2022/Adobe_Photoshop_2022_Settings.tar.xz" > $CD/../payloads/Adobe_Photoshop_2022_Settings.tar.xz
fi
tar -xf $CD/../payloads/Adobe_Photoshop_2022_Settings.tar.xz
mkdir -p $install//drive_c/users/$USER/AppData/Roaming/Adobe
mkdir -p $install//drive_c/users/$USER/AppData/Roaming/Adobe/Adobe\ Photoshop\ 2022/
rsync -avpP Adobe\ Photoshop\ 2022\ Settings $install//drive_c/users/$USER/AppData/Roaming/Adobe/Adobe\ Photoshop\ 2022/
# rm -rf Adobe_Photoshop_2022_Settings.tar.xz
# rm -rf Adobe\ Photoshop\ 2022\ Settings


touch ~/.local/share/applications/photoshop.desktop
echo '[Desktop Entry]' >> ~/.local/share/applications/photoshop.desktop
echo 'Name=Photoshop CC 2022' >> ~/.local/share/applications/photoshop.desktop
echo 'Exec=bash -c "'$install'//drive_c/launcher.sh %F"' >> ~/.local/share/applications/photoshop.desktop
echo 'Type=Application' >> ~/.local/share/applications/photoshop.desktop
echo 'Comment=Photoshop CC 2022 (Wine)' >> ~/.local/share/applications/photoshop.desktop
echo 'Categories=Graphics;' >> ~/.local/share/applications/photoshop.desktop
echo 'Icon=photoshop' >> ~/.local/share/applications/photoshop.desktop
echo 'StartupWMClass=photoshop.exe' >> ~/.local/share/applications/photoshop.desktop


# rm -rf allredist
# rm -rf winetricks

rm -rf $install/progress.mimifile
touch $install/progress.mimifile
echo "100" >> $install/progress.mimifile

unlink  $CD/install
ln -s $(basename $install) install

sleep 5

rm -rf $install/progress.mimifile
rm -rf $install/photoshop2022install.sh
