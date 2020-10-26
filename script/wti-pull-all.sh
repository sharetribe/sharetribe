#!/bin/bash

set -e

if [[ -f .wti.main && -f .wti.admin ]] ; then
    echo "Pulling main Go interface translations..."
    cp .wti.main .wti && wti pull

    echo "Pulling Go Admin panel translations..."
    cp .wti.admin .wti && wti pull

    rm -f .wti
else
    echo "No .wti.main or .wti.admin files found. Are you running this script from the Go project root directory?"
    exit 1
fi
