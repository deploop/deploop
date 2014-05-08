#!/bin/bash
# Both puppet master and puppet agent have pseudo-RESTful HTTP API’s that 
# they use to communicate. The basic structure of the url to access this API is:
#
# https://yourpuppetmaster:8140/{environment}/{resource}/{key}
# https://yourpuppetclient:8139/{environment}/{resource}/{key}
#
# For testing disable the security with this entry in the last line
# of /etc/puppet/auth.conf (danger mode)
#
# path /
# auth any
# allow *
#
# Also we have to enable insecure invocations of curl 
# which are specified with the -k or --insecure flag.

# For secure invocations:
# SSL_PATH=/var/lib/puppet/ssl/
# HOST=openbus-deploop.openstacklocal
#
# curl --cert ${SSL_PATH}/certs/${HOST}.pem \
#     --key ${SSL_PATH}/private_keys/${HOST}.pem \
#     --cacert ${SSL_PATH}/ca/ca_crt.pem \
#     -H 'Accept: yaml' https://puppet:8140/production/catalog/${HOST}

# Instead of using YAML for network communication, PSON or JSON should be used. 

# Get a catalog from the node.
HOST=openbus-rm.openstacklocal
curl -w "\n" --insecure -H 'Accept: pson' https://puppet:8140/production/catalog/${HOST}
