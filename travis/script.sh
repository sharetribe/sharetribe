#!/bin/bash

set -e

echo "Running script"
echo "SUITE: ${SUITE}"

# Somehow Travis uses a different version of Node.js even after
# running install.sh if we don't set up nvm again here.

# shellcheck source=/dev/null
. "$HOME/.nvm/nvm.sh"
nvm install
nvm use

if [ "$SUITE" = "rspec" ]
then
    bundle exec rspec spec 2>&1
    exit
elif [ "$SUITE" = "rubocop" ]
then
    bundle exec rubocop -V
    bundle exec rubocop -R 2>&1
    exit
elif [ "$SUITE" = "cucumber" ]
then
    echo "PhantomJS version:"
    (cd client && npm run print-phantomjs-version)

    echo "Running npm rebuild node-sass"
    (cd client && npm rebuild node-sass)

    echo "Running npm run clean"
    npm run clean

    echo "Build translation bundle"
    script/export_translations.sh

    echo "Build routes bundle"
    script/export_routes_js.sh

    echo "Running client and server builds"
    (cd client && npm run build:client && npm run build:server)

    echo "Starting PhantomJS and Cucumber"
    (cd client && npm run start-phantomjs) &
    PHANTOMJS=true bundle exec cucumber -ptravis 2>&1
    exit
elif [ "$SUITE" = "lint" ]
then
    cd client && npm run lint 2>&1
    exit
fi
