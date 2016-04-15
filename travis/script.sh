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
    phantomjs --version
    echo "Running client and server builds"
    echo "Running npm rebuild node-sass"
    npm rebuild node-sass
    echo "Running npm run clean"
    npm run clean
    (cd client && npm run build:client && npm run build:server)
    phantomjs --webdriver=8910 &
    PHANTOMJS=true bundle exec cucumber -ptravis 2>&1
    exit
elif [ "$SUITE" = "eslint" ]
then
    cd client && npm run lint 2>&1
    exit
fi
