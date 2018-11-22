#!/usr/bin/env bash

set -e

FILE="./client/app/i18n/all.js"

if [ -f $FILE ];
then
    echo "Skipping translation export task. Translation bundle ${FILE} exists already."
else
    echo "Exporting translations..."
    bundle exec rake i18n:js:export
    echo "Translations exported to ${FILE}"
fi
