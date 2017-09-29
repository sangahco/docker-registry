#!/bin/sh

set -e

if [ "$NAMESERVERS" == "" ]; then
    export NAMESERVERS=$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' ')
fi

envsubst '$NAMESERVERS' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf

exec nginx -g "daemon off;" "$@"