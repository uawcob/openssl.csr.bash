#!/bin/bash

# InCommon's provided X509 Base64 encoded certificates are malformed.
# The blocks are listed with root first, ending with client certificate.
#
# Per IETF's RFC 5246 Section 7.4.2
# https://tools.ietf.org/html/rfc5246#section-7.4.2
#
#       This is a sequence (chain) of certificates.  The sender's
#       certificate MUST come first in the list.  Each following
#       certificate MUST directly certify the one preceding it.
#
# This script downloads the certificates and appends them in the correct order.

[[ $1 ]] || {
    echo "InCommon Self-Enrollment Certificate ID required."
    exit 1
}

hash curl 2>/dev/null || {
    echo "curl required."
    exit 1
}

url='https://cert-manager.com/customer/InCommon/ssl?action=download&sslId='"$1"

curl "$url"'&format=x509CO'
echo
curl "$url"'&format=x509IOR'
