#!/bin/bash

set -e

echo "Running before_script"
echo "SUITE: ${SUITE}"

case "$SUITE" in
    rspec|cucumber)
        echo "Setting up database for $SUITE"
        cp config/database.example.yml config/database.yml
        mysql -e 'create database sharetribe_test;'
        bundle exec rake db:test:load
        ;;
esac
