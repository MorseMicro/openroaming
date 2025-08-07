#!/bin/bash

# Copyright 2025 Morse Micro
# SPDX-License-Identifier: GPL-2.0-or-later

set -ue -o pipefail

EXPECTED_VERSION=23.05

MYDIR=$(dirname $0)
PATCHDIR=""$MYDIR/patches

failure() {
	echo Failed to adapt your existing OpenWrt. The most probably cause
	echo of this is that you have local changes that are incompatible.
	echo You should look at the particular patch/operation that failed,
	echo and adjust it appropriately.
	exit 1
}

trap failure ERR

if ! [ -e include/version.mk ]; then
	echo "Can't detect OpenWrt version (no include/version.mk)."
	echo "Make sure you're running this script in your OpenWrt directory."
	echo
	exit 1
fi

if ! grep -q "^VERSION_NUMBER:=.*,$EXPECTED_VERSION" include/version.mk; then
	echo "Cannot find $EXPECTED_VERSION in default VERSION_NUMBER."
	echo "This feed is intended for OpenWrt $EXPECTED_VERSION based distributions."
	echo "and may not function as expected on other versions"
	echo
fi

find "$PATCHDIR" -type f -name '*.patch' | while read -r patch_file; do
	rel_path="${patch_file#$PATCHDIR/}"
	target_dir="$(dirname "$rel_path")"

	if [ ! -d "$target_dir" ]; then
		echo "$target_dir does not exist."
		echo "Skipping..."
		echo
	fi

	echo "Applying $(basename "$patch_file") to $target_dir"
	patch -p1 -d"$target_dir" < "$patch_file"
done


echo "
Successfully adapted OpenWrt to add Morse support.
"
