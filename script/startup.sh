#!/bin/bash

set -e

# Expect to be passed either 'web' or 'worker' as parameter
APP_MODE="${1-web}"

case "$APP_MODE" in
    web)
        if [[ "$MAINTENANCE_MODE" == "true" ]] ; then
            exec /usr/sbin/nginx -p /opt/app -c config/nginx_maintenance.conf
        else
            rm -f tmp/pids/server.pid

            exec bundle exec passenger \
                 start \
                 -p "${PORT-3000}" \
                 --log-file "/dev/stdout" \
                 --min-instances "${PASSENGER_MIN_INSTANCES-1}" \
                 --max-pool-size "${PASSENGER_MAX_POOL_SIZE-1}"
        fi
        ;;
    worker)
        if [[ "$MAINTENANCE_MODE" == "true" ]] ; then
            # Do nothing
            exec sleep 86400
        else
            exec bundle exec rake jobs:work
        fi
        ;;
    *)
        echo "Unknown process type. Must be either 'web' or 'worker'!"
        exit 1
        ;;
esac
