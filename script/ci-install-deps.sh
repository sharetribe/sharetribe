#!/bin/bash

set -eo pipefail

# Google APT key signatures have changed and we need to update the key for apt
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google.asc >/dev/null

sudo apt-get update
sudo apt-get install -y default-libmysqlclient-dev default-mysql-client sphinxsearch

if [[ -f ~/.nvm/nvm.sh ]] ; then
    echo "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
fi

source ~/.nvm/nvm.sh

nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
