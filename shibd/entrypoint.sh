#!/bin/sh

set -e

TIME=0.1
KEYS=/var/shib-keys/keys

echo "Waiting for $KEYS..."
while [ ! -s "$KEYS" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $KEYS!"

echo "Waiting for $SHIBSP_CONFIG..."
while [ ! -s "$SHIBSP_CONFIG" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $SHIBSP_CONFIG!"

exec /usr/sbin/shibd -F -f
