#!/bin/bash

# Exit code is 0 (true) if assets should be rebuilt

set -e

COMPARE_SHA="${1-HEAD}"

# Make sure cached revision exists
[ "$(git cat-file -t "$COMPARE_SHA")" != "commit" ] && return 0

# TODO consider if only ancestors should be treated as valid cache

CHANGES=$(git diff --shortstat "$COMPARE_SHA" -- \
              app/assets \
              client \
              package.json \
              vendor/assets)

[ -n "$CHANGES" ]
