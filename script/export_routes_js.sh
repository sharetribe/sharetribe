#!/usr/bin/env bash

set -e

FILE="./client/app/routes/routes.js"

if [ -f $FILE ];
then
    echo "Skipping routes export task. Routes file ${FILE} exists already."
else
    echo "Exporting routes..."
    bundle exec rake js:routes
    echo "Routes exported to ${FILE}"
fi
