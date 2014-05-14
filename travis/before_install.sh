#!/bin/bash

echo "Running before_install"
echo "SUITE: ${SUITE}"

if [ "$SUITE" = "rspec" ]
then
	"echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
	gem install bundler bundle_cache
	bundle_cache_install
	exit
elif [ "$SUITE" = "rubocop" ]
then
	"echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
	gem install bundler bundle_cache
	bundle_cache_install
	exit
elif [ "$SUITE" = "cucumber" ]
then
	"echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
	gem install bundler bundle_cache
	bundle_cache_install
	exit
elif [ "$SUITE" = "mocha" ]
then
	"echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
	gem install bundler bundle_cache
	bundle_cache_install
	npm install
	npm install -g grunt-cli
	exit
elif [ "$SUITE" = "jshint" ]
then
	npm install
	npm install -g grunt-cli
	exit
else
	echo -e "Error: SUITE is illegal or not set\n"
	exit 1
fi