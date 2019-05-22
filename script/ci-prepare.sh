#!/bin/bash

set -e

source ~/.nvm/nvm.sh

( cd client && npm rebuild node-sass )

npm run clean
script/export_translations.sh
script/export_routes_js.sh

(cd client && npm run build:client && npm run build:server )
