#!/usr/bin/env bash

source 'script/wait_for_file.sh'

routes_js='client/app/routes/routes.js'

echo "Waiting for $routes_js..."

wait_for_file "$routes_js" 30 || {
  echo "Routes file missing after waiting for 30 seconds: '$routes_js'"
  exit 1
}

echo "$routes_js found"
