#!/usr/bin/env bash

source 'script/wait_for_file.sh'

server_js='app/assets/webpack/server-bundle.js'

echo "Waiting for $server_js..."

wait_for_file "$server_js" 30 || {
  echo "Server JS bundle missing after waiting for 30 seconds: '$server_js'"
  exit 1
}

echo "$server_js found"
