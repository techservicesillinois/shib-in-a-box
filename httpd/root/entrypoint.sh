#!/bin/sh

set -e 

TIME=0.1

[[ -z "$ELMR_HOSTNAME" ]] && echo "ELMR_HOSTNAME not set!" && exit 1
[[ -z "$LB_HOSTNAME" ]] && echo "LB_HOSTNAME not set!" && exit 1
[[ -z "$LOG_LEVEL" ]] && echo "LOG_LEVEL not set!" && exit 1

# By default, delete config files used for testing
[[ -z "$ENABLE_ELMR_CONFIG" ]] && rm /etc/httpd/conf.d/elmr_config.conf
[[ -z "$ENABLE_DEBUG_PAGES" ]] && rm /etc/httpd/conf.d/debug.conf
[[ -z "$ENABLE_MOCK_SHIBD" ]] && rm /etc/httpd/conf.d/mock_shib.conf

echo "Waiting for $SHIBSP_CONFIG..."
while [ ! -s "$SHIBSP_CONFIG" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $SHIBSP_CONFIG!"

exec httpd -DFOREGROUND
