#!/bin/bash

echo "Running before_install"
echo "SUITE: ${SUITE}"

"echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
gem install bundler bundle_cache
bundle_cache_install

if [ "$SUITE" = "rspec" ]
then
	exit
elif [ "$SUITE" = "cucumber" ]
then
	exit
elif [ "$SUITE" = "mocha" ]
then
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