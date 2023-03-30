# Adobe-Linux
This fork of `MiMillieuh/Photoshop-CC2022-Linux` uses `make` to build self-contained appimages with wine+Adobe application and all the required dependencies so the Adobe Application runs in any linux distro. 

This was only possible thanks to @MiMillieuh amazing work on [`MiMillieuh/Photoshop-CC2022-Linux`](https://github.com/MiMillieuh/Photoshop-CC2022-Linux)! Thanks man!! 

I know a lot of people hate appimages, but I find it perfect to pack functional windows application, together with the correct wine and dependencies so the application runs in any distro without the need to install anything!

The cherry on the top, in my opnion, is the use of fuse `unionfs` to re-mount the appimage as a writable folder, owned by the user running the appimage, so wine is happy with it's `wineprefix` ownership and permissions! 

Everything the application tries to write to the `wineprefix/drive_c` folder is written to an `$HOME/adobe-application` folder.

## Currently working applications
| Version  | Wine | Rating |
| ------------- | ------------- | ------------- |
| Photoshop 2022 | 8.4 | Works almost like on Windows  |
| Photoshop 2023 | 8.4 |Launches but gives some DXVK errors - the canvas doesnt show correctly |
| Substance Painter 8.3.0 | 8.4 | Works perfectly |

## Before building
This Makefile requires a fully functional Windows Virtual Machine present in your local network, named `adobe.local`, with Adobe Creative Cloud software properly running, able to download and install the applications in the Windows Virtual Machine `c:/Adobe` folder. 

The Windows Virtual Machine needs:

  * install the latest Windows 10 in your virtual machine, and use `adobe.local` as hostname and `game` as main administrator username. (the Makefile will try to login using `ssh game@adobe.local`)

  * install Cygwin ssh server + rsync. [You can follow this tutorial to install ssh server](https://7thzero.com/blog/how-to-install-cygwin-and-configure-ssh). When selecting `ssh` in the cygwin installer, don't forget to also select `rsync`. (I strong recommend setting up paswordless ssh login so the Makefile can run unnanted. Google for "Passwordless SSH Login" and you find plenty tutorials on how to do it)

  * install Adobe Creative Cloud from adobe.com website, login, set the installation folder for apps to `c:/Adobe` before installing what you want to pack as appimage.

## Build
Run `make help` to see how to use it. 

## How it works
The Makefile downloads the latest `wine` version directly from WineHQ website. It downloads the Ubuntu 18.04 version, for maximum compatibility with other distros.

It then uses the downloaded wine to run a variation of `MiMillieuh/Photoshop-CC2022-Linux` scripts, which creates the wineprefixes for the required application. 

After that is done, the Makefile uses `rsync` to copy over the installed application from the `adobe.local` virtual machine, as well as other required folders like `C:/Program Files*/Adobe` and `C:/Program Files*/Common Files`. 

Then it sets up an appimage folder based on the `appimage-template`, and creates the actual appimage file. 

Once it's finish, running the application.appimage should launch the Adobe Application correctly, in Linux. 




