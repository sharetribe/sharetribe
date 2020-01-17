#!/bin/bash

set -eo pipefail

sudo ./script/setup-mysql-apt-repo.sh

sudo apt-get install libmysqlclient-dev mysql-community-client sphinxsearch

if [[ -f ~/.nvm/nvm.sh ]] ; then
    echo "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
fi

source ~/.nvm/nvm.sh

nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
