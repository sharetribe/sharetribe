#!/bin/bash

set -e

echo "Running install"
echo "SUITE: ${SUITE}"

bundle install --without development --path=~/.bundle
