#!/bin/bash

set -e

echo "Running before_install"

# Assert that the given SUITE is a known one
case "$SUITE" in
    rspec|rubocop|cucumber|lint)
        echo "SUITE: ${SUITE}"
        ;;
    *)
        echo "Error: empty or unknown SUITE: $SUITE"
        # This stops the whole build, and thus the SUITE check is not
        # needed in other build phases
        exit 1
        ;;
esac

echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

gem install nokogiri -- --use-system-libraries
gem install bundler specific_install
# Install a modified version of bundle_cache gem
# If the modifications get merged to bundle_cache use the upstream repo, not this one
gem specific_install https://github.com/sharetribe/bundle_cache
bundle_cache_install
