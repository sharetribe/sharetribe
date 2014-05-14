#!/bin/bash

echo "Running script"
echo "SUITE: ${SUITE}"

if [ "$SUITE" = "rspec" ]
then
	bundle exec rake spec 2>&1
	exit
elif [ "$SUITE" = "rubocop" ]
then
	bundle exec rubocop -R 2>&1
	exit
elif [ "$SUITE" = "cucumber" ]
then
	phantomjs --webdriver=8910 &
	PHANTOMJS=true bundle exec cucumber -ptravis 2>&1
	exit
elif [ "$SUITE" = "mocha" ]
then
	grunt connect mocha 2>&1
	exit
elif [ "$SUITE" = "jshint" ]
then
	grunt jshint 2>&1
	exit
else
	echo -e "Error: SUITE is illegal or not set\n"
	exit 1
fi