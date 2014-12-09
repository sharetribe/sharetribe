#!/bin/bash

echo "Running before_install"
echo "SUITE: ${SUITE}"

if [ "$SUITE" = "mocha" ]
then
	npm install
	npm install -g grunt-cli
	exit
elif [ "$SUITE" = "jshint" ]
then
	npm install
	npm install -g grunt-cli
	exit
fi
