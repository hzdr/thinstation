# Thinstation - HZDR fork

This repository hosts a fork of the Linux-based [Thinstation](http://github.com/Thinstation/thinstation) thin client project. It comes with some modifications to:

* get Thinstation running more smoothly and optimized on the [intel NUC](http://www.intel.eu/content/www/eu/en/nuc/overview.html) platform. Tested/Supported models are:
  * [D54250WYK](http://www.intel.eu/content/www/eu/en/nuc/nuc-kit-d54250wyk.html)
  * [D34010WYK](http://www.intel.eu/content/www/eu/en/nuc/nuc-kit-d34010wyk.html)
  * [DE3815TYKHE](http://www.intel.com/content/www/us/en/nuc/nuc-kit-de3815tykhe.html)
  * [DC3217BY](http://www.intel.eu/content/www/eu/en/motherboards/desktop-motherboards/desktop-kit-dc3217by.html)
  * [DC3217IYE](http://www.intel.eu/content/www/eu/en/motherboards/desktop-motherboards/desktop-kit-dc3217iye.html)
  * [DCCP847DYE](http://www.intel.com/content/www/us/en/nuc/nuc-kit-dccp847dye.html)
* provide a lightweight kiosk system which after bootup provides a simple connection GUI with options to connect via [ThinLinc](http://www.cendio.se/), RDP (via [freerdp](http://www.freerdp.com)) and VNC to Linux and Windows Terminalservers
* provide an adapted user interface to the needs of our organization ([Helmholtz-Zentrum Dresden-Rossendorf](http://www.hzdr.de/))

While this fork seems to be only interested for the HZDR organization, it comes with modifications to Thinstation which might be interested to a wider range of users (including potential patches for the upstream 'Thinstation' project), thus this github-hosted project.

## Installation
There are only a few points to get this Thinstation version compiled for being put on a PXE server:

1. perform a clean github checkout of hzdr/thinstation:

   ```
   git clone https://github.com/hzdr/thinstation.git thinstation-hzdr
   cd thinstation-hzdr
   ```

2. put proper `id_rsa` and `id_rsa.pub` file in ts/5.2 directory:

   ```
   cp id_rsa ts/5.2
   cp id_rsa.pub ts/5.2
   ```

3. run the build and automatically install the pxe images (make sure `/tftpboot` exists):

   ```
   ./mkhzdr
   ``` 

## License
As the original Thinstation project is licensed under the GPL license, this fork and all its source components are also distributed under the GPL (GNU General Public License) Open Source License.

## Summary of modifications (July 2014)
The following should provide a short list of major modifications in comparison to the original Thinstation project:

* created a new 'hzdr' package in `ts/5.2/packages/hzdr' with the following components:
  * binaries of 'qutselect' package providing a Qt4-based user interface to start remote RDP, ThinLinc and VNC connections.
  * binaries of 'xfwm4' including an adapted theme to use as a lightweight window manager around qutselect
  * binaries of 'keyd' keyboard daemon to be able to define own keyboard shortcuts (see `/etc/keyd.conf`) to perform tasks within the context of the thin client OS (e.g. ejecting mounted drives, modifying volume, etc.)
  * binaries of 'xte' keyboard emulation to allow to lock a remote session with a simple keyboard shortcut in the context of the thin client OS
  * modifications to generate an optimized ThinLinc configuration file to perform remote connections with only minor user input.
  * special udev and acpi scripts to automatically move audio output on demand to a different device (e.g. as soon as headphones are plugged in)
  * own pulseaudio configuration file to allow to switch audio output sinks even in a running ThinLinc session.
* hightly optimized `build.conf` to generate a small PXE image (~ 48 MB only) with only the necessary packages included and `fastboot=lostofmem` enabled.
* own `mkhzdr` install script to perform the necessary steps (even interactively) to generate the PXE images and directly install them in /tftpboot/thinstation

## Credits
The HZDR fork of Thinstation is brought to you by:

* Jens Maus
* Alexandr Lougovski
