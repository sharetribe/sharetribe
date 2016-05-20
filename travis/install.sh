#!/bin/bash

set -e

echo "Running install"
echo "SUITE: ${SUITE}"

case "$SUITE" in
    rspec|rubocop|cucumber)
        echo "Running bundle install for suite: $SUITE"
        bundle install --without development --path=~/.bundle
        ;;
esac

case "$SUITE" in
    cucumber|lint)
        echo "Installing and selecting Node.js version with nvm for suite: $SUITE"
        # shellcheck source=/dev/null
        . "$HOME/.nvm/nvm.sh"
        nvm install
        nvm use
        nvm alias default "$(cat .nvmrc)"

        echo "Node.js version:"
        node --version
        echo "NPM version:"
        npm --version

        npm install
        ;;
esac
