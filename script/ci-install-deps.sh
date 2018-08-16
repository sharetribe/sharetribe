#!/bin/bash

set -eo pipefail

echo 'deb http://deb.debian.org/debian jessie-backports main' | sudo tee -a /etc/apt/sources.list

sudo apt-get update && sudo apt-get install -y sphinxsearch mysql-client

if [[ -f ~/.nvm/nvm.sh ]] ; then
    echo "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
fi

source ~/.nvm/nvm.sh

nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
