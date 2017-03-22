# Thinstation - HZDR fork

This repository hosts a fork of the Linux-based [Thinstation](http://github.com/Thinstation/thinstation) thin client project. It comes with some modifications to:

* get Thinstation running more smoothly and optimized for the various thin clients used at our institution. Tested and supported models are:
  * 7th Gen Intel NUC (Kaby-Lake): [NUC7i3BNK/NUC7i3BNH](http://www.intel.de/content/www/us/en/nuc/nuc-kit-nuc7i3bnk.html)
  * 6th Gen Intel NUC (Skylake): [NUC6i3SYB/NUC6i5SYB](http://www.intel.de/content/www/us/en/nuc/nuc-kit-nuc6i5syk.html)
  * 5th Gen Intel NUC (Broadwell): [NUC5i3RYB/NUC5i5RYB](http://www.intel.de/content/www/us/en/nuc/nuc-kit-nuc5i3ryk.html)
  * 4th Gen Intel NUC (Haswell): [D34010WYB/D54250WYB](http://www.intel.de/content/www/us/en/nuc/nuc-kit-d34010wykh-board-d34010wyb.html)
  * 3th Gen Intel NUC (Atom): [DE3815TYBE](http://www.intel.de/content/www/us/en/nuc/nuc-kit-de3815tykhe-board-de3815tybe.html)
  * 2th Gen Intel NUC (Ivy Bridge): [D33217GK](http://www.intel.com/content/www/us/en/support/boards-and-kits/intel-nuc-boards/intel-nuc-board-d33217gk.html)
  * 1st Gen Intel NUC (Sandy Bridge): [DCP847SKE](http://www.intel.de/content/www/us/en/nuc/nuc-kit-dccp847dye-board-dcp847ske.html)
  * [Fujitsu Futro S700](http://www.fujitsu.com/de/products/computing/pc/thin-clients/FUTRO-S700/)
  * [Fujitsu Futro S550-2](http://globalsp.ts.fujitsu.com/dmsp/Publications/public/ds-FUTRO-S550-2.pdf)
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

2. put proper `id_rsa` and `id_rsa.pub` file in ts/build directory:

   ```
   cp id_rsa ts/build
   cp id_rsa.pub ts/build
   ```

3. run the build and automatically install the pxe images (make sure `/tftpboot` exists):

   ```
   sudo ./mkhzdr
   ``` 

## License
As the original Thinstation project is licensed under the GPL license, this fork and all its source components are also distributed under the GPL (GNU General Public License) Open Source License.

## Summary of modifications (April 2015)
The following should provide a short list of major modifications in comparison to the original Thinstation project:

* created a new 'hzdr' package in `ts/build/packages/hzdr' with the following components:
  * binaries of 'qutselect' package (https://github.com/hzdr/qutselect) providing a Qt-based user interface to start remote RDP, ThinLinc and VNC connections.
  * binaries of 'xfwm4' including an adapted theme to use as a lightweight window manager around qutselect
  * binaries of 'keyd' keyboard daemon to be able to define own keyboard shortcuts (see `/etc/keyd.conf`) to perform tasks within the context of the thin client OS (e.g. ejecting mounted drives, modifying volume, etc.)
  * binaries of 'xte' keyboard emulation to allow to lock a remote session with a simple keyboard shortcut in the context of the thin client OS
  * modifications to generate an optimized ThinLinc configuration file to perform remote connections with only minor user input (no user/password asked).
  * special udev and acpi scripts to automatically move audio output on demand to a different device (e.g. as soon as headphones are plugged in)
  * own pulseaudio configuration file to allow to switch audio output sinks even during a running ThinLinc session.
* hightly optimized `build.conf` (see ts/build/conf/hzdr)to generate a small PXE image (~ 48 MB only) with only the necessary packages included and `fastboot=lostofmem` enabled.
* own `mkhzdr` install script to perform the necessary steps (even interactively) to generate the PXE images and directly install them in /tftpboot/thinstation

## Credits
The HZDR fork of Thinstation is brought to you by:

* Jens Maus &lt;j.maus@hzdr.de&gt;
* Alexandr Lougovski
