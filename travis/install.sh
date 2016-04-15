#!/bin/bash

set -e

echo "Running install"
echo "SUITE: ${SUITE}"

bundle install --without development --path=~/.bundle

echo "Installing and selecting Node.js version with nvm"
# shellcheck source=/dev/null
. "$HOME/.nvm/nvm.sh"
nvm install
nvm use

echo "Node.js version:"
node --version
echo "NPM version:"
npm --version

npm install
