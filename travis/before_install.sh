#!/bin/bash

echo "Running before_install"
echo "SUITE: ${SUITE}"

"echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"

if [ "$SUITE" = "rspec" ]
then
	gem install nokogiri -- --use-system-libraries
	gem install bundler specific_install
	# Install a modified version of bundle_cache gem
	# If the modifications get merged to bundle_cache use the upstream repo, not this one
	gem specific_install https://github.com/sharetribe/bundle_cache
	bundle_cache_install
	exit
elif [ "$SUITE" = "rubocop" ]
then
	gem install nokogiri -- --use-system-libraries
	gem install bundler specific_install
	# Install a modified version of bundle_cache gem
	# If the modifications get merged to bundle_cache use the upstream repo, not this one
	gem specific_install https://github.com/sharetribe/bundle_cache
	bundle_cache_install
	exit
elif [ "$SUITE" = "cucumber" ]
then
	gem install nokogiri -- --use-system-libraries
	gem install bundler specific_install
	# Install a modified version of bundle_cache gem
	# If the modifications get merged to bundle_cache use the upstream repo, not this one
	gem specific_install https://github.com/sharetribe/bundle_cache
	bundle_cache_install
	exit
elif [ "$SUITE" = "mocha" ]
then
	gem install nokogiri -- --use-system-libraries
	gem install bundler specific_install
	# Install a modified version of bundle_cache gem
	# If the modifications get merged to bundle_cache use the upstream repo, not this one
	gem specific_install https://github.com/sharetribe/bundle_cache
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