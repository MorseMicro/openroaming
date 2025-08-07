This repository is an OpenWrt feed incorporating a number of minor changes
and some packages to ease the repeatability of an OpenRoaming capable OpenWrt
build. This feed primarily targets the Morse Micro 
[OpenWrt fork](https://github.com/MorseMicro/openwrt), based on OpenWrt 23.05, 
but some of the patches and packages may be applicable to other forks.

Contents
========

| File/Dir | Description |
| --- | --- |
| *setup_openwrt.sh* | script for automatically applying patches (see below) |
| *profile_extractor.sh* | script for parsing Android client profiles |
| *patches* | patches to apply to the OpenWrt distribution |
| *packages* | OpenWrt packages to help deploy OpenRoaming |


Configuration
============

1.  Clone or checkout a new branch in your existing OpenWrt repository.

2.  Make sure you can succesfully build and flash a an image
    for your device, and validate that it works correctly.

3.  In your cloned OpenWrt repository copy `feeds.conf.default` to `feeds.conf`
    and add this repository feed:

        src-git openroaming https://github.com/MorseMicro/openroaming.git

4.  Update the local package indexes to add the morse packages:

        ./scripts/feeds update openroaming
        ./scripts/feeds install -p openroaming -a

5.  Add/apply the `patches` directory to your main tree by running:

        ./feeds/openroaming/setup_openwrt.sh

    This will add a small number of required patches to the OpenWrt base tree
    and some patches to other feeds, if they exist. Please look at the script
    output for more information. After doing this, consider checking in
    the changes. Make sure to add the new files!


Build and run
=============

1.  Run `make menuconfig` and choose from the following packages as you 
    require:
    * radsec-bundle: for deploying a default set of RADIUS server and radsec
      configuration files should these services be co-located on the AP.
    * wireless-bundle: for deploying a default set of configuration files
      to Wi-Fi radios.
    
    If using the radsec-bundle, optionally define `CONFIG_OR_OPERATOR_NAME`,
    `CONFIG_OR_RADIUS_CLIENT_SECRET`, `CONFIG_OR_RADSEC_CERT`, 
    `CONFIG_OR_RADSEC_KEY`, and/or `CONFIG_OR_RADSEC_CA_CERT` to deploy the
    same configuration to your build image.
    Alternatively, you will need to update 
    `/etc/freeradius3/sites-enabled/default`, `/etc/freeradius3/clients.conf`,
    `/etc/freeradius3/proxy.conf` and `/etc/config/radsecproxy` manually after 
    booting the device.
    Due to a circular dependency with configuration options, radsec-bundle will
    require you to select `CONFIG_PACKAGE_radsecproxy`, 
    `CONFIG_PACKAGE_freeradius3`, and `CONFIG_PACKAGE_freeradius3-default`.

    If using the wireless-bundle, you will need to modify `/etc/config/wireless`
    to enable the appropriate interfaces as required. This may include
    installing a client certificate into `/etc/ssl/certs` or configuring the
    RADIUS server secrets for the AP.

2.  Make and install a new image to your device as before.

3. For a minimal client, use `profile_extractor.sh` on a downloaded android
   profile to extract the client certificate and credentials. The cert can be
   copied to the target device, and or_client_radio# updated with the extracted
   credentials.
   Remove `option disabled '1'`, and `reload_config` to bring up a client
   interface.

4. For an AP, edit the appropriate `or_ap_radio#` to target your desired radius
   authentication and accounting servers and their secrets.
