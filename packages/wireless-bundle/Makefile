#
# Copyright 2025 Morse Micro
#
# SPDX-License-Identifier: GPL-2.0-or-later
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wireless-bundle
PKG_RELEASE=1

PKG_MAINTAINER:=Morse Micro

include $(INCLUDE_DIR)/package.mk

define Package/wireless-bundle
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenRoaming Wireless Configuration Bundle
endef

define Package/wireless-bundle/description
 This package contains some default configuration for OpenWrt APs and
 clients.
endef

define Build/Compile
endef

define Package/wireless-bundle/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/openroaming-wireless-defaults $(1)/etc/uci-defaults/openroaming-wireless-defaults
endef

$(eval $(call BuildPackage,wireless-bundle))
