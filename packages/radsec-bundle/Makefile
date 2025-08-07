#
# Copyright 2025 Morse Micro
#
# SPDX-License-Identifier: GPL-2.0-or-later
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radsec-bundle
PKG_RELEASE=1

PKG_MAINTAINER:=Morse Micro

include $(INCLUDE_DIR)/package.mk

define Package/radsec-bundle
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenRoaming RadSec/RADIUS Configuration Bundle
  DEPENDS:= radsecproxy \
            freeradius3 \
            freeradius3-default
endef

define Package/radsec-bundle/config
  source "$(SOURCE)/Config.in"
endef

define Package/radsec-bundle/description
 This package contains minor config/scripts adaptations for
 deploying RADIUS server and radsec components to a device.
endef

define Build/Compile
	if [ -n $(CONFIG_OR_RADSEC_CA_CERT) ]; then \
		touch $(PKG_BUILD_DIR)/ca.crt; \
		for f in $(CONFIG_OR_RADSEC_CA_CERT); do \
			if [ ! -f "$$$$f" ]; then \
				echo "Error: CA certificate '$$$$f' not found!" >&2; exit 1; \
			fi; \
			cat "$$$$f" >> $(PKG_BUILD_DIR)/ca.crt; echo >> $(PKG_BUILD_DIR)/ca.crt; \
		done \
	fi


	sed \
		-e 's/CONFIG_OR_RADIUS_CLIENT_SECRET/$(CONFIG_OR_RADIUS_CLIENT_SECRET)/g' \
		./files/etc/uci-defaults/openroaming-radsecproxy \
		> $(PKG_BUILD_DIR)/openroaming-radsecproxy

	chmod +x $(PKG_BUILD_DIR)/openroaming-radsecproxy

	sed \
		-e 's/CONFIG_OR_OPERATOR_NAME/$(CONFIG_OR_OPERATOR_NAME)/g' \
		./files/etc/freeradius3/sites-enabled/default \
		> $(PKG_BUILD_DIR)/freeradius3-default
	
	sed \
		-e 's/CONFIG_OR_RADIUS_CLIENT_SECRET/$(CONFIG_OR_RADIUS_CLIENT_SECRET)/g' \
		./files/etc/freeradius3/proxy.conf \
		> $(PKG_BUILD_DIR)/proxy.conf

	sed \
		-e 's/CONFIG_OR_RADIUS_CLIENT_SECRET/$(CONFIG_OR_RADIUS_CLIENT_SECRET)/g' \
		./files/etc/freeradius3/clients.conf \
		> $(PKG_BUILD_DIR)/clients.conf
endef

define Package/radsec-bundle/install
	$(INSTALL_DIR) $(1)/etc/openroaming/certs
	$(INSTALL_DIR) $(1)/etc/openroaming/private
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/lib/openroaming/scripts
	$(INSTALL_DIR) $(1)/etc/freeradius3/openroaming/sites-enabled

ifneq ($(CONFIG_OR_RADSEC_CERT),)
	$(INSTALL_DATA) "$(CONFIG_OR_RADSEC_CERT)" $(1)/etc/openroaming/certs/entity.crt
endif

ifneq ($(CONFIG_OR_RADSEC_KEY),)
	$(INSTALL_DATA) "$(CONFIG_OR_RADSEC_KEY)" $(1)/etc/openroaming/private/entity.key.pem
endif

ifneq ($(CONFIG_OR_RADSEC_CA_CERT),)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ca.crt $(1)/etc/openroaming/certs/ca.crt
endif

	$(INSTALL_DATA) ./files/etc/openroaming/certs/README $(1)/etc/openroaming/certs/README
	$(INSTALL_DATA) ./files/etc/openroaming/private/README $(1)/etc/openroaming/private/README
	$(INSTALL_BIN) ./files/usr/lib/openroaming/scripts/naptr-openroaming.sh $(1)/usr/lib/openroaming/scripts/naptr-openroaming.sh
	$(INSTALL_DATA) ./files/etc/uci-defaults/openroaming-freeradius3 $(1)/etc/uci-defaults/openroaming-freeradius3

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openroaming-radsecproxy $(1)/etc/uci-defaults/openroaming-radsecproxy
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/freeradius3-default $(1)/etc/freeradius3/openroaming/sites-enabled/default
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/proxy.conf $(1)/etc/freeradius3/openroaming/proxy.conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/clients.conf $(1)/etc/freeradius3/openroaming/clients.conf
endef

$(eval $(call BuildPackage,radsec-bundle))
