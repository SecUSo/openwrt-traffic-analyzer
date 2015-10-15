# Copyright 2015 Sebastian Fach
# Copyright 2015 Daniel Franke
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=trafficanalyzer
PKG_RELEASE:=0.1.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/trafficanalyzer
  SECTION:=luci
  CATEGORY:=LuCI
  DEPENDS:=+privoxy
  TITLE:=Trafficanalyzer which uses privoxy to analyze http traffic and warn the user if she transmits login credentials over http.
endef

define Package/trafficanalyzer/description
Trafficanalyzer is an OpenWrt addon which includes a LuCi configuration interface extension. It uses privoxy to display the user a warning if she enters her login credentials on a webpage which does not transmit them encrypted.
After installation, you have to open the setup webpage of the addon, select the interface which should be configured to route http traffic over privoxy and run the setup script.
Warning: All http-traffic on the selected interface will be redirected over privoxy and privoxy will block LuCi. So you should use another Interface to access LuCi or use ssh for command line configuration. The setup does not redirect other ports or blocks forwarding to other interfaces. Please configure the firewall if you want to block all other traffic from or to the selected interface (http://wiki.openwrt.org/doc/uci/firewall).
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/trafficanalyzer/install
	$(CP) ./dist/* $(1)/
endef

define Package/trafficanalyzer/postinst
	/etc/init.d/privoxy enable
endef

define Package/trafficanalyzer/prerm
	if [ -e /etc/privoxy/added_by_trafficanalyzer ]; then
	/etc/uci-defaults/trafficanalyzer_setup.sh uninstall;
	fi;
	rm -rf /www/luci-static/resources/warningpage
endef

$(eval $(call BuildPackage,trafficanalyzer))
