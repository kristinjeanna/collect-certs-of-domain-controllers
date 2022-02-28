#!/bin/sh

EXPECTED_ARGS=2

if [ $# -ne $EXPECTED_ARGS ]; then
    echo "Incorrect args: $#"
    echo "Usage: $0 {domain name} {PEM filename}"
    for var in "$@"; do
        echo $var
    done
    exit 1
fi

DOMAIN=$1
OUTPUT=$2

domain_controllers=$(nslookup -type=srv _ldap._tcp.dc._msdcs.${DOMAIN} | awk '{print $7}' | sed -r '/^\s*$/d' | sort)

for dc in ${domain_controllers}; do
    echo "connecting to DC: ${dc}"
    echo "QUIT" | \
        openssl s_client -connect ${dc}:636 2>/dev/null | \
        openssl x509 >> ${OUTPUT}
done
