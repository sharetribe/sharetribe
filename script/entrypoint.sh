#!/bin/bash

set -e

if [[ -n "$SECURE_ENVIRONMENT_URL" && -n "$SECURE_ENVIRONMENT_KEY" ]] ; then
    # Decrypted secure environment variables
    eval $(/usr/sbin/secure-environment export)
fi

exec "$@"
