#!/bin/bash

rm -f tmp/pids/server.pid

exec bundle exec passenger start -p "${PORT-3000}" --max-pool-size "${PASSENGER_MAX_POOL_SIZE-1}"
