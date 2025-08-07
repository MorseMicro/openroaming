#!/bin/sh

#
# Copyright 2025 Morse Micro
# SPDX-License-Identifier: GPL-2.0-or-later
#

set -eu
#set -x

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Usage: $0 <android_profile>"
  exit 1
fi

TMP_INPUT="$(mktemp)"
base64 -d "$INPUT_FILE" > "$TMP_INPUT"

BOUNDARY=$(grep -m1 -oP '^Content-Type: multipart/mixed; boundary=\K.*' "$TMP_INPUT" | tr -d '\r')

if [ -z "$BOUNDARY" ]; then
  echo "Boundary not found." >&2
  rm -f "$TMP_INPUT"
  exit 1
fi

csplit -s -f part_ -b "%02d.tmp" "$TMP_INPUT" "/--$BOUNDARY/" '{*}'

for FILE in part_*.tmp; do
  if grep -q "application/x-passpoint-profile" "$FILE"; then
    awk 'BEGIN{found=0} /^$/ {found=1; next} found {print}' "$FILE" | base64 -d > profile.xml
  elif grep -q "application/x-x509-ca-cert" "$FILE"; then
    {
      echo "-----BEGIN CERTIFICATE-----"
      awk 'BEGIN{found=0} /^$/ {found=1; next} found {print}' "$FILE"
      echo "-----END CERTIFICATE-----"
    } > or-client.crt
    echo "Exported PEM-formatted certificate to or-client.crt"
  fi
done

rm -f "$TMP_INPUT" part_*.tmp

if [ ! -f profile.xml ]; then
  echo "profile.xml not found." >&2
  exit 1
fi

extract_value_after_nodename() {
  awk -v key="$1" '
    $0 ~ "<NodeName>" key "</NodeName>" {
      getline
      if ($0 ~ /<Value>/) {
        match($0, /<Value>([^<]*)<\/Value>/, a)
        print a[1]
      }
    }
  ' profile.xml
}

ROAMING=$(extract_value_after_nodename "RoamingConsortiumOI")
USERNAME=$(extract_value_after_nodename "Username")
PASSWORD_B64=$(extract_value_after_nodename "Password")
PASSWORD=$(printf "%s" "$PASSWORD_B64" | base64 -d 2>/dev/null)
EAPTYPE=$(extract_value_after_nodename "EAPType")
INNER=$(extract_value_after_nodename "InnerMethod")

if [ "$EAPTYPE" != "21" ]; then
	echo "Script only supports ttls" >&2
	exit 1
fi

echo "---- Credentials ----"
echo "RoamingConsortiumOI: $ROAMING"
echo "Username: $USERNAME"
echo "Password (decoded): $PASSWORD"
echo "EAPType: ttls ($EAPTYPE)"
echo "InnerMethod: $INNER"

rm profile.xml
