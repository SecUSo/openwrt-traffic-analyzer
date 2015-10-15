# Wificloner

## Description
Trafficanalyzer is an OpenWrt addon which includes a LuCi configuration interface extension. It uses privoxy to display the user a warning if she enters her login credentials on a webpage which does not transmit them encrypted.
After installation, you have to open the setup webpage of the addon, select the interface which should be configured to route http traffic over privoxy and run the setup script.
Warning: All http-traffic on the selected interface will be redirected over privoxy and privoxy will block LuCi. So you should use another Interface to access LuCi or use ssh for command line configuration. The setup does not redirect other ports or blocks forwarding to other interfaces. Please configure the firewall if you want to block all other traffic from or to the selected interface (http://wiki.openwrt.org/doc/uci/firewall).



### Installation via opkg
1. Copy the ipk-file suitable for you platform from the package directory to your Openwrt system.
2. call opkg install trafficanalyzer_0.1.0_<platform_type>.ipk (e.g. trafficanalyzer_0.1.0_x86.ipk for the x86 version).

That’s it.

### Manual Installation
1. Copy all files/folders from package-dev/luci-trafficanalyzer/dist/ to the root folder of your Openwrt system.
2. Reboot the system.

### Create your own package
1. Build and/or install the Openwrt sdk (http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk)
2. copy the Wificloner subfolder from package-dev to the packages subfolder of the sdk
3. Open command line, navigate to the sdk-folder and run make 
4. The package can be found in the folder bin/<platform name>/packages/base/

## Folders

### packages
Contains precompiled ipk-packages for some popular platforms.

### package-dev
Contains files used to create an ipk-package with the Openwrt sdk (see section "create your own package" for more information).
Does only contain stable releases created with the version from dev-folder.

### dev
This folder contains the development version of the addon. Development takes place with the luci develompent environment (http://luci.subsignal.org/trac/wiki/Documentation/DevelopmentEnvironmentHowTo).
The subfolder luci-wificloder can be directly used in the environment if you copy it to the application subfolder of the sdk.
The sdk creates a folder called distribution which can be used for the package creation (package dev). 


