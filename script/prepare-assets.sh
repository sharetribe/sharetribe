#!/bin/bash

set -e

# Use supplied assets tarball or compile assets, if it doesn't exist
if [ -f "assets.tar.gz" ] ; then
    tar vxfz assets.tar.gz
else
    # Set dummy database connection string
    export DATABASE_URL="mysql2://user:pass@127.0.0.1/dummy"

    # Set dummy AWS credentials
    export AWS_ACCESS_KEY_ID="dummy-id"
    export AWS_SECRET_ACCESS_KEY="dummy-key"

    # Edit the script/asset-variables.sh file to e.g. set font locations, icon pack, etc.
    [ -f "script/asset-variables.sh" ] && source "script/asset-variables.sh"

    export secret_key_base=$(ruby -r securerandom -e "puts SecureRandom.hex(64)")
    export SECRET_KEY_BASE="$secret_key_base"

    bundle exec rake assets:precompile
fi
