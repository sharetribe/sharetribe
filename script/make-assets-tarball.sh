#!/bin/bash

set -e

tar cfz assets.tar.gz \
    app/assets/javascripts/i18n \
    app/assets/webpack \
    client/app/i18n \
    client/app/routes \
    public/assets \
    public/webpack
