#!/bin/bash
site_name="example.walton.uark.edu"
email_address="wcobhelp@uark.edu"
organization="University of Arkansas"
organizational_unit="Sam M. Walton College of Business"
country="US"
state="AR"
city="Fayetteville"

use_subject_alternative_names=true

# common name MUST also be included as subject alternative name
# per RFC 6125 (https://tools.ietf.org/html/rfc6125#section-6.4.4), published in 2011:
# the validator must check SAN first, and if SAN exists, then CN should not be checked.
# http://stackoverflow.com/a/5937270/4233593
# failure to include CN as one of the SANs will result in certificate errors in some browsers
declare -a subject_alternative_names=(
  "$site_name"
  "*.$site_name"
)

set -e

if [ ! -d outssl ]; then
  mkdir outssl
fi

command="openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout \"outssl/$site_name.key\" -out \"outssl/$site_name.csr\" -subj \"/emailAddress=$email_address/CN=$site_name/O=$organization/OU=$organizational_unit/C=$country/ST=$state/L=$city\""

if $use_subject_alternative_names; then

  sanstring=""
  for san in "${subject_alternative_names[@]}"; do
    sanstring="$sanstring""DNS:$san,"
  done
  # trim trailing comma
  sanstring="${sanstring::-1}"

  if [[ -z "$OPENSSL_CONF" ]]; then
    # get default openssl.cnf
    # thanks Jeff Walton http://stackoverflow.com/a/37042289/4233593
    opensslcnf="$(openssl version -d | cut -d '"' -f2)/openssl.cnf"
  else
    opensslcnf="$OPENSSL_CONF"
  fi

  command="$command -reqexts SAN -config <(cat \"$opensslcnf\" <(printf \"[SAN]\nsubjectAltName=$sanstring\"))"

fi

eval "$command"
