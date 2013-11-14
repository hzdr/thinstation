# Thinstation - HZDR fork

This repository hosts a fork of the Linux-based [Thinstation](https://github.com/Thinstation/thinstation) thin client project. It comes with some modifications to:

* get Thinstation running more smoothly and optimized on the [intel NUC](http://www.intel.com/content/www/us/en/motherboards/desktop-motherboards/nuc.html) platform
* provide a lightweight kiosk system which after bootup provides a simple connection GUI with options to connect via [ThinLinc](http://www.cendio.se/), RDP (via [freerdp](http://www.freerdp.com)) and VNC to Linux and Windows Terminalservers
* provide an adapted user interface to the needs of our organization ([Helmholtz-Zentrum Dresden-Rossendorf](http://www.hzdr.de/))

While this fork seems to be only interested for the HZDR organization, it comes with modifications to Thinstation which might be interested to a wider range of users (including potential patches for the upstream 'Thinstation' project), thus this github-hosted project.

## Installation
There are only a few points to get this Thinstation version compiled for being put on a PXE server:

1. perform a clean github checkout of hzdr/thinstation:

  ```
  git clone https://github.com/hzdr/thinstation.git thinstation-hzdr
  ```

2. prepare the setup chroot environment:

   ```
   cd thinstation-hzdr
   sudo ./setup-chroot
   ```

3. put proper `id_rsa` and `id_rsa.pub` file in ts/5.1 directory:

   ```
   cp id_rsa ts/5.1
   cp id_rsa.pub ts/5.1
   ```

4. run the build and automatically install the pxe images (make sure `/tftpboot` exists):

   ```
   ./mkhzdr
   ``` 

## License
As the original Thinstation project is licensed under the GPL license, this fork and all its source components are also distributed under the GPL (GNU General Public License) Open Source License.

## Summary of modifications
The following should provide a short list of major modifications in comparison to the original Thinstation project (as of November 2013):

* created a new 'intel_nuc' machine within Thinstation with firmware and kernel module optimizations
* created a new 'hzdr' package in `ts/5.1/packages/hzdr' with the following components
  * binaries of 'qutselect' package providing a Qt4-based user interface to start remote RDP, ThinLinc and VNC connections.
  * binaries of 'openbox' including an adapted theme to use as a lightweight window manager
  * binaries of 'keyd' keyboard daemon to be able to define own keyboard shortcuts (see `/etc/keyd.conf`) to perform tasks within the context of the thin client OS (e.g. ejecting mounted drives, modifying volume, etc.)
  * binaries of 'xte' keyboard emulation to allow to lock a remote session with a simple keyboard shortcut in the context of the thin client OS
  * modifications to generate an optimized ThinLinc configuration file to perform remote connections with only minor user input.
* optimized `build.conf` to generate a small PXE image (~ 40 MB only) with only the necessary packages included and `fastboot=lostofmem` enabled.
* downgraded/tested version of freerdp (1.0.3-dev) to fix issues with multi-monitor and session redirection environments with the 1.1 versions of freerdp.
* own `mkhzdr` install script to perform the necessary steps (even interactively) to generate the PXE images and directly install them in /tftpboot/thinstation
* minor fixes and adaptions to general Thinstation functionality (see changes in our [upstream](https://github.com/hzdr/thinstation/compare/upstream) branch)

## Credits
The HZDR fork of Thinstation is brought to you by:

* Jens Maus <mail@jens-maus.de>
* Alexandr Lougovski
