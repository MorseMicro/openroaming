#! /bin/sh
#set -x
# Rev. 20250725

# NAPTR/SRV lookup script for OpenRoaming with 3GPP realm conversion.
# Ref. "WBA OpenRoaming - The Framework to Support WBA's Wi-Fi Federation"
#   Version 3.0.0
# This script rewrites the original 3GPP realm
#   wlan.mncXXX.mccYYY.3gppnetwork.org
# into a modified one
#   wlan.mncXXX.mccYYY.pub.3gppnetwork.org , 
# and tries NAPTR/SRV lookup.
# No fallback to the original realm is performed.

# Note:
# 3GPP TS23.003 defines the realm wlan.mnc<mnc>.mcc<mcc>.3gppnetwork.org
# for use in EAP-SIM, AKA and AKA'.
# These realms are NOT resolvable from the public internet.
# Instead, GSMA IR.67 defines the use of
# wlan.mnc<mnc>.mcc<mcc>.pub.3gppnetwork.org for OpenRoaming based
# dynamic peer discovery from public internet.

# Example script!
# This script looks up radsec srv records in DNS for the one
# realm given as argument, and creates a server template based
# on that. It currently ignores weight markers, but does sort
# servers on priority marker, lowest number first.

# Note:
# This script is a replication of the work done by Prof. Hideaki Goto
# but limited to use busybox nslookup with naptr query additions.
# Retrieved: https://github.com/wireless-broadband-alliance/openroaming-config/blob/main/radsecproxy/naptr-openroaming.sh


usage() {
    echo "Usage: ${0} <realm> [<NAPTR tag>]"
    exit 1
}

test -n "${1}" || usage

NSCMD=$(command -v nslookup)
PRINTCMD=$(command -v printf)
test -n "${2}" && NAPTRTAG="${2}" || NAPTRTAG="aaa+auth:radius.tls.tcp"

validate_host() {
	echo ${@} | tr -d '\n\t\r' | grep -E '^[_0-9a-zA-Z][-._0-9a-zA-Z]*$'
}

validate_port() {
	echo ${@} | tr -d '\n\t\r' | grep -E '^[0-9]+$'
}

ns_it_srv() {
	${NSCMD} -type=srv "$SRV_HOST" | grep "$SRV_HOST" | sort -n -k4 |
	while read -r line; do
		set $line ; PORT=$(validate_port "$6") ; HOST=$(validate_host "$7")
		if [ -n "${HOST}" ] && [ -n "${PORT}" ]; then
			$PRINTCMD "\thost ${HOST%.}:${PORT}\n"
		fi
	done
}

ns_it_naptr() {
	${NSCMD} -type=naptr ${REALM} | grep "$NAPTRTAG" | sort -n -k4 |
	while read -r line; do
		set $line ; TYPE=$6 ; HOST=$(validate_host $9)
		if { [ "$TYPE" = "\"s\"" ] || [ "$TYPE" = "\"S\"" ]; } && [ -n "${HOST}" ]; then
			SRV_HOST=${HOST%.}
			ns_it_srv
		fi
	done
}

REALM=$(validate_host "${1}")
if [ -z "${REALM}" ]; then
	echo "Error: realm \"${1}\" failed validation"
	usage
fi

REALM_0=$REALM
if [[ "$REALM" =~ "3gppnetwork" ]]; then
	REALM=${REALM_0/3gppnetwork/pub.3gppnetwork}
fi

if [ -x "${NSCMD}" ]; then
	SERVERS=$(ns_it_naptr)
else
	echo "${0} requires \"nslookup\"."
	exit 1
fi

if [ -n "${SERVERS}" ]; then
	$PRINTCMD "server dynamic_radsec.${REALM_0} {\n${SERVERS}\n\ttype TLS\n}\n"
	exit 0
fi

exit 10