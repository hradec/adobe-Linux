
CD:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL:=/bin/bash
VERSION?=
STUDIO=frankbarton

$(info $(shell /usr/bin/env python3 -c 'print("="*120)'))
$(shell rm -f *.log)
# SUBVERSION=$(shell cat Adobe\ Photoshop\ $(VERSION)/AMT/application.xml | sed "s/[>,<]/\n/g" | grep ProductVersion -A1 | tail -1)
SUBVERSION?=$(shell ./scripts/adobeGetPhotoshopSubversion.sh $(VERSION) )
WINE_VERSION?=$(shell ./scripts/wine-dowloader.sh -l 2>/dev/null | tail -1 | awk '{print $$1}' )
$(info Wine Version: $(WINE_VERSION))
ifneq "$(VERSION)" ""
$(info Version: $(VERSION))
endif
ifneq "$(SUBVERSION)" ""
$(info Subversion: $(SUBVERSION))
endif
$(info $(shell /usr/bin/env python3 -c 'print("="*120)'))

all: help

help:
	@echo ""
	@echo "make help                                         - display this help screen."
	@echo "make substance VERSION=<substance version number> - build substance appimage"
	@echo "make photoshop VERSION=<photoshop version number> - build photoshop appimage"
	# @echo "make wineprefix                                   - make booth wineprefix for substance and photoshop"
	@echo "make wine [WINE_VERSION=<version of wine>]        - downloads wine from wineHQ"
	@echo "make winels                                       - list all versions of wine available for download"
	@echo "make clean                                        - cleanup."
	@echo "make clean_folders                                - cleanup wine and wineprefixes."
	@echo "make clean_all                                    - cleanup appimages temporary folders."
	@echo "make nuke                                         - cleanup all temporary folders above + adobe applications folder."
	@echo "make pgrep                                        - display wine processes."
	@echo "make pkill                                        - kill wine processes."
	@echo "make pullvm                                       - pull all adobe apps from VM"
	@echo ""

# prepare to build
build/.prepared:
	mkdir -p ./build
	touch build/.prepared

# list wine processes
pgrep:
	@pgrep -fa '\\.exe|\.exe|wine|adobe' | egrep -v 'unionfs|rsync|rclone|ssh|bin.bash' || echo "No wine processes running!"

# kill wine processes
pkill:
	@kill -9 $$(pgrep -fa '\\.exe|\.exe|wine|adobe' | egrep -v 'unionfs|rsync|rclone|ssh|bin.bash' | awk '{print $$1}')

# force the use of one shell for all shell lines, instead of one shell per line.
.ONESHELL:
# check if we have the VERSION variable specified. We can't proceed without it
checks:
	@if [ "$(VERSION)" == "" ] ; then
	 	echo -e "\n\nSpecify the version to build!!\n"
		exit -1
	else
		# force check of subversion
		rm -rf ./build/Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/AMT/application.xml
		# force rsync of wineprefix_photoshop to the appimage
		rm -rf ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wineprefix/system.reg
	fi

# check if adobe.local is online! Fail if it's not.
checkVM:
	@if [ "$$(ping -c 3 -W 2 adobe.local | grep ' 0%')" == "" ] ; then
	 	echo -e "\n\nThe adobe.local vm that contains adobe applications already installed is not online!!\n"
		exit -1
	fi

# create the substance appimage
substance: checks adobe-substance-painter-$(VERSION).appimage
adobe-substance-painter-$(VERSION).appimage: checks checkVM build/wine/$(WINE_VERSION)/bin/wine64 build/wineprefix_substance/system.reg build/AdobeSubstance3DPainter
		@python3 -c "print('='*120)"
		mkdir -p build/appimage-adobe-substance-painter-$(VERSION)/wine
		rsync -avpP ./build/wine/$(WINE_VERSION)/ ./build/appimage-adobe-substance-painter-$(VERSION)/wine/$(WINE_VERSION)/
		ln -s $(WINE_VERSION) ./build/appimage-adobe-substance-painter-$(VERSION)/wine/current
		rsync -avpP ./appimage-template/ ./build/appimage-adobe-substance-painter-$(VERSION)/
		rsync -avpP ./scripts/run.sh ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/
		chmod a+x ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/run.sh
		rsync -avpP ./icons/substance.png ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/myapp.png
		rsync -avpP --delete --delete-excluded ./build/wineprefix_substance/ ./build/appimage-adobe-substance-painter-$(VERSION)/wineprefix/
		cat ./appimage-template/AppRun \
			| sed 's/__APP__/substance/' \
			| sed 's/__STUDIO__/$(STUDIO)/' \
		> ./build/appimage-adobe-substance-painter-$(VERSION)/AppRun
		chmod a+x ./build/appimage-adobe-substance-painter-$(VERSION)/AppRun
		rsync -avpP ./build/AdobeSubstance3DPainter/ ./build/appimage-adobe-substance-painter-$(VERSION)/Adobe\ Substance\ 3D\ Painter/
		rm -rf ./build/appimage-adobe-substance-painter-$(VERSION)/main.exe
		ln -s Adobe\ Substance\ 3D\ Painter/Adobe\ Substance\ 3D\ Painter.exe ./build/appimage-adobe-substance-painter-$(VERSION)/main.exe
		cd ./build
		../scripts/appimage-build.sh ./appimage-adobe-substance-painter-$(VERSION)
		mv substance.appimage ../adobe-substance-painter-$(VERSION).appimage

# create the phothoshop appimage
photoshop: checks adobe-photoshop-$(VERSION).$(SUBVERSION).appimage
adobe-photoshop-$(VERSION).$(SUBVERSION).appimage: checks checkVM build/wine/$(WINE_VERSION)/bin/wine64 /dev/shm/SUBVERSION build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wineprefix/system.reg
		@python3 -c "print('='*120)"
		mkdir -p build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wine
		rsync -avpP ./build/wine/$(WINE_VERSION)/ ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wine/$(WINE_VERSION)/
		ln -s $(WINE_VERSION) ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wine/current
		rsync -avpP ./appimage-template/ ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/
		rsync -avpP ./scripts/run.sh ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/
		chmod a+x ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/run.sh
		rsync -avpP ./icons/photoshop.png ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/myapp.png
		cat ./appimage-template/AppRun \
			| sed 's/__APP__/photoshop/' \
			| sed 's/__STUDIO__/$(STUDIO)/' \
		> ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/AppRun
		chmod a+x ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/AppRun
		rsync -avpP ./build/Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/ ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/
		rm -rf ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/main.exe
		ln -s Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/Photoshop.exe ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/main.exe
		cd ./build
		../scripts/appimage-build.sh ./appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)
		mv photoshop.appimage ../adobe-photoshop-$(VERSION).$(SUBVERSION).appimage

# download wine version specified in $WINE_VERSION
build/wine/$(WINE_VERSION)/bin/wine64: build/.prepared
	cd ./build
	../scripts/wine-dowloader.sh -v $(WINE_VERSION)
	touch ./wine/$(WINE_VERSION)/bin/wine64

# just list available downloads at WineHQ website!
winels: build/.prepared
	cd ./build
	../scripts/wine-dowloader.sh -l

# create all wineprefixes
wineprefix: build/wineprefix_substance/system.reg build/wineprefix_photoshop/system.reg
# create wineprefix for substance
build/wineprefix_substance/system.reg: build/wine/$(WINE_VERSION)/bin/wine64 scripts/adobeEnvironmentInstall.sh
	@cd ./build
	../scripts/adobeEnvironmentInstall.sh 	wineprefix_substance
	touch wineprefix_substance/system.reg

# create wineprefix for photoshop
build/wineprefix_photoshop/system.reg: build/wine/$(WINE_VERSION)/bin/wine64 scripts/adobeEnvironmentInstall.sh
	@cd ./build
	../scripts/adobeEnvironmentInstall.sh 	wineprefix_photoshop
	touch wineprefix_photoshop/system.reg

# rsync photoshop wineprefix to the appimage build folder
build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wineprefix/system.reg: build/wineprefix_photoshop/system.reg
	mkdir -p build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wine
	rsync -avpP --delete --delete-excluded ./build/wineprefix_photoshop/ ./build/appimage-adobe-photoshop-$(VERSION).$(SUBVERSION)/wineprefix/

# check if we actually have a $SUBVERSION for photoshop!! Fail if we don't!
/dev/shm/SUBVERSION:
	# @./scripts/adobeGetPhotoshopSubversion.sh $(VERSION) > /dev/shm/SUBVERSION
	# cat build/Adobe\ Photoshop\ $(VERSION)/AMT/application.xml | sed "s/[>,<]/\n/g" | grep ProductVersion -A1 | tail -1 > /dev/shm/SUBVERSION
	echo $(SUBVERSION) > /dev/shm/SUBVERSION
	@if [ "$$(cat /dev/shm/SUBVERSION)" == "" ] ; then
		@python3 -c "print('='*120)"
		echo "Can't get photoshop subversion. Does the ./build/Adobe\ Photoshop\ $(VERSION)/AMT/application.xml file exists?"
		@python3 -c "print('='*120)"
		exit -1
	else
		@python3 -c "print('='*120)"
		echo "building adobe-photoshop-$(VERSION).$$(cat /dev/shm/SUBVERSION).appimage"
		@python3 -c "print('='*120)"
	fi

# pull all applications from adobe.local
pullvm: checks build/AdobeSubstance3DPainter bbuild/Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/AMT/application.xml
# pull substance from adobe.local vm
build/AdobeSubstance3DPainter:
	rsync -avpP --no-perms --no-owner --no-group --delete --delete-excluded game@adobe.local:'/cygdrive/c/Adobe/Adobe\ Substance\ 3D\ Painter/'   ./build/AdobeSubstance3DPainter/

# pull photoshop from adobe.local vm
build/Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/AMT/application.xml: /dev/shm/SUBVERSION checks checkVM build/wineprefix_photoshop/system.reg
	python3 -c "print('='*120)"
	rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files/Adobe'                   ./build/wineprefix_photoshop/drive_c/Program\ Files/
	rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files/Common\ Files'           ./build/wineprefix_photoshop/drive_c/Program\ Files/
	rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files\ \(x86\)/Adobe'          ./build/wineprefix_photoshop/drive_c/Program\ Files\ \(x86\)/
	rsync -avpP --no-perms --no-owner --no-group                            game@adobe.local:'/cygdrive/c/Program\ Files\ \(x86\)/Common\ Files'  ./build/wineprefix_photoshop/drive_c/Program\ Files\ \(x86\)/
	rsync -avpP --no-perms --no-owner --no-group --delete --delete-excluded game@adobe.local:'/cygdrive/c/Adobe/Adobe\ Photoshop\ $(VERSION)/'    ./build/Adobe\ Photoshop\ $(VERSION).$(SUBVERSION)/

# cleanup stuff
clean:
	rm -rf build/.prepared

clean_folders: clean
	rm -rf build/wineprefix_*
	rm -rf build/wine

clean_all: clean
	rm -rf appimage_*

nuke:
	rm -rf build
