#!/bin/bash

set -e

# Use supplied assets tarball or compile assets, if it doesn't exist
if [ -f "assets.tar.gz" ] ; then
    tar vxfz assets.tar.gz
else
    # Set dummy database connection string
    export DATABASE_URL="mysql2://user:pass@127.0.0.1/dummy"

    # Edit the script/asset-variables.sh file to e.g. set font locations, icon pack, etc.
    [ -f "script/asset-variables.sh" ] && source "script/asset-variables.sh"

    secret_key_base=$(ruby -r securerandom -e "puts SecureRandom.hex(64)")
    export secret_key_base

    bundle exec rake assets:precompile
fi
