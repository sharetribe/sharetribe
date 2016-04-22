#!/bin/bash

set -e

echo "Running script"
echo "SUITE: ${SUITE}"

if [ "$SUITE" = "rspec" ]
then
    bundle exec rspec spec 2>&1
    exit
elif [ "$SUITE" = "rubocop" ]
then
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

    echo "Running client and server builds"
    (cd client && npm run build:client && npm run build:server)

    echo "Starting PhantomJS and Cucumber"
    (cd client && npm run start-phantomjs) &
    PHANTOMJS=true bundle exec cucumber -ptravis 2>&1
    exit
elif [ "$SUITE" = "eslint" ]
then
    cd client && npm run lint 2>&1
    exit
fi
