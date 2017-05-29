source 'http://rubygems.org'

ruby '2.3.1'

gem 'rails', '5.1.1'

gem 'coffee-rails'
gem 'uglifier'

gem 'sass-rails'
gem 'compass-rails'

gem 'jquery-rails'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem "passenger"

gem "mysql2"
gem 'haml'
gem 'sass'
gem 'rest-client'

gem 'paperclip'
gem 'delayed_paperclip'

gem 'aws-sdk'
gem "will_paginate"
gem 'dalli'
gem "memcachier"
gem 'readthis'
gem 'hiredis'
gem 'thinking-sphinx'
gem 'flying-sphinx'
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta',
  :git    => 'https://github.com/pat/ts-delayed-delta.git',
  :branch => 'master',
  :ref    => '839284f2f28b3f4caf3a3bf5ccde9a6d222c7f4d'
gem 'possibly'

gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'web_translate_it'
gem 'rails-i18n'
gem 'devise'
gem 'devise-encryptable'
gem "omniauth-facebook"

# Dynamic form adds helpers that are needed, e.g. error_messages
gem 'dynamic_form'
gem "truncate_html"
gem 'money-rails'

# The latest release (0.9.0) is not Rails 4 compatible
gem 'mercury-rails',
  git: 'https://github.com/jejacks0n/mercury.git',
  branch: 'master',
  ref: '1cc637b0bccea19085f824d2881c6513ed5ee8ae'

gem 'countries'
gem "mail_view"
gem 'statesman'
gem "premailer"
gem 'stringex'
gem 'paypal-sdk-permissions'
gem 'paypal-sdk-merchant'
gem 'airbrake'

gem 'jwt'

# Use Oauth2 from current master, because the newest release
# uses old JWT version
# (This can be removed when oauth2 version > 1.1.0 is released)
gem 'oauth2',
  git: 'https://github.com/intridea/oauth2.git',
  branch: 'master',
  ref: 'e0006cb5099bf392f011eb5c49cbec4f893bbdba'

gem 'lograge'
gem 'public_suffix' # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

# Session store was removed from Rails 4
gem 'activerecord-session_store'

# This gem was added to make Rails 3.2 -> 4 upgrade path easier.
# It adds `attr_protected` and `attr_accessor` methods to models.
# We should remove this gem before upgrading to Rails 5
gem 'protected_attributes_continued'

gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-encoding'

gem "react_on_rails", "~>6.9.0"

gem "css_parser"
gem 'sitemap_generator'

# Use latest from master
#
# The latest master is needed because it contains the I18n.extend configuration
# See: https://github.com/fnando/i18n-js/pull/397
gem "i18n-js",
    git: "https://github.com/fnando/i18n-js.git",
    branch: "master",
    ref: "2ca6d31365bb41db21e373d126cac00d38d15144"

# A store scoped to the request object for caching
gem "request_store"

group :staging, :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'rubocop', require: false
  gem 'factory_girl_rails'
end

group :development, :staging do
  gem 'meta_request'
end

group :development do
  gem 'rb-fsevent', require: false
  gem 'guard-rspec', require: false
  gem 'annotate'
  gem 'zeus', require: false
  gem 'better_errors'
  gem 'web-console'
  gem 'awesome_print'
end

group :test do
  gem 'capybara'
  gem "rspec-rails"

  gem 'cucumber-rails', require: false # require: false is needed for cucumber-rails

  gem 'selenium-webdriver'

  # Launchy is needed by Capybara, e.g. save_and_open command needs Launchy to open a browser
  gem 'launchy'
  gem 'email_spec'
  gem 'timecop'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'connection_pool'
  gem 'rails-controller-testing'

  # required for CircleCI automatic test balancing
  gem 'rspec_junit_formatter'
end

group :development, :test do
  gem 'pry-byebug'
end


gem 'therubyracer', platforms: :ruby
gem 'js-routes'

# Color utilities needed for landing page
gem 'color'

gem 'uuidtools'
gem 'transit-ruby'

# Markdown parser
gem 'redcarpet'

gem 'intercom'
