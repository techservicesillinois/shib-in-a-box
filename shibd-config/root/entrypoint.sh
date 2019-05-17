#!/bin/sh

set -e

RETURN_CODE=0

function get_ip_addr() {
    # $1 is var to set with IP
    # $2 is hostname to lookup
    local TIME=0.1
    local IP

    if [ -z "$2" ]; then
        # Assuming we are running in awsvpc mode
        IP="127.0.0.1"
    else
        # Assuming we are running in Bridge mode or docker-compose
        echo "Waiting for IP to become avaliable from HOST '$2'..."
        while [ -z "$IP" ]; do
            IP=$(getent ahosts $2 | awk 'NR==1{ print $1 }')
            echo "    Sleeping for $TIME seconds."
            sleep $TIME
        done
        echo "HOST $2 has the IP: $IP."
    fi

    eval export $1=$IP
}

function log_level_test() {
    # $1 is var to test

    local valid_log_levels="OFF FATAL ERROR WARN INFO DEBUG TRACE ALL"

    if [ -z "$2" ] || ! [[ " $valid_log_levels " =~ .*\ $2\ .* ]]
    then
        echo "$2 should be one of $valid_log_levels"
        echo "Setting the default log level to INFO"
        eval export $1=INFO
        eval export RETURN_CODE=1
    fi
}

[[ -z "$ENTITY_ID" ]] && echo "ENTITY_ID not set!" && exit 1

get_ip_addr HTTPD_IP "$HTTPD_HOSTNAME"
get_ip_addr SHIBD_IP "$SHIBD_HOSTNAME"

/usr/local/bin/get-shib-keys

sed -i -e "s/SHIBD_ACL/$HTTPD_IP/g" \
       -e "s/SHIBD_IP/$SHIBD_IP/g" \
       -e "s;ENTITY_ID;$ENTITY_ID;g" \
       -e "s;SUPPORT_CONTACT;$SUPPORT_CONTACT;g" \
    $SHIBSP_CONFIG_TEMPLATE

log_level_test SHIBD_LOG_LEVEL "$SHIBD_LOG_LEVEL"
log_level_test MOD_SHIB_LOG_LEVEL "$MOD_SHIB_LOG_LEVEL"

sed -i -e "s/LOG_LEVEL/$SHIBD_LOG_LEVEL/g" \
    $SHIBD_LOG

sed -i -e "s/LOG_LEVEL/$MOD_SHIB_LOG_LEVEL/g" \
    $MOD_SHIB_LOG

mv $SHIBSP_CONFIG_TEMPLATE $SHIBSP_CONFIG

exit $RETURN_CODE
