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
  echo "Node.js version:"
  node --version
  echo "NPM version:"
  npm --version
  foreman start -f Procfile.spec &
  phantomjs --webdriver=8910 &
  PHANTOMJS=true bundle exec cucumber -ptravis 2>&1
  exit
elif [ "$SUITE" = "eslint" ]
then
  echo "Node.js version:"
  node --version
  echo "NPM version:"
  npm --version
  cd client && npm run lint 2>&1
  exit
fi
