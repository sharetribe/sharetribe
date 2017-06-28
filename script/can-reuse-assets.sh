#!/bin/bash

# Exit code is 0 (true) if given old version of assets can be reused

set -e

COMPARE_SHA="${1-HEAD}"

# Make sure cached revision exists
[ "$(git cat-file -t "$COMPARE_SHA")" == "commit" ]

# TODO consider if only ancestors should be treated as valid cache

CHANGES=$(git diff --shortstat "$COMPARE_SHA" -- \
              app/assets \
              client \
              config/locales \
              package.json \
              vendor/assets)

[ -z "$CHANGES" ]
