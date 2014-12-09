#!/bin/bash

echo "Running install"
echo "SUITE: ${SUITE}"

if [ "$SUITE" = "rspec" ]
then
	bundle install --without development --deployment --jobs=3 --retry=3 --path=${BUNDLE_PATH:-vendor/bundle}
	exit
elif [ "$SUITE" = "rubocop" ]
then
  	bundle install --without development --deployment --jobs=3 --retry=3 --path=${BUNDLE_PATH:-vendor/bundle}
  	exit
elif [ "$SUITE" = "cucumber" ]
then
	bundle install --without development --deployment --jobs=3 --retry=3 --path=${BUNDLE_PATH:-vendor/bundle}
	exit
elif [ "$SUITE" = "mocha" ]
then
	bundle install --without development --deployment --jobs=3 --retry=3 --path=${BUNDLE_PATH:-vendor/bundle}
	exit
elif [ "$SUITE" = "jshint" ]
then
	exit
else
	echo -e "Error: SUITE is illegal or not set\n"
	exit 1
fi
