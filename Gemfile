source 'http://rubygems.org'

ruby '2.3.1'

gem 'rails', '4.2.7.1'

gem 'coffee-rails', "~> 4.0.1"
gem 'uglifier', "~> 2.7.2"

gem 'sass-rails', '~> 4.0.0'
gem 'compass-rails', '~> 2.0'

# Requiring 'compass' gem directly is not normally needed,
# 'compass-rails' already does that.
#
# However, we want to have compass version which is at least 0.13,
# because it fixes a bug that caused compass helpers to override
# important Rails asset helpers
gem 'compass', '~> 0.13.alpha'

gem 'jquery-rails', '3.1.3'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem "passenger", "~> 5.0.18"

gem "mysql2", "~> 0.3.14"
gem 'haml', "~> 4.0.5"
gem 'sass', "  ~> 3.2.9"
gem 'rest-client', '~> 1.8.0'

gem 'paperclip', '~> 4.3.6'
gem 'delayed_paperclip', "~> 2.9.1"

gem 'aws-sdk-v1', "~> 1.64.0"
gem 'aws-sdk', '~> 2'
gem "will_paginate", '~>3.0.5'
gem 'dalli', "~> 2.6.4"
gem "memcachier", "~> 0.0.2"
gem 'kgio', "~>2.9.2"
gem 'thinking-sphinx', '~> 3.1.1'
gem 'flying-sphinx', "~>1.2.0"
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta', "~>2.0.2",
  :git    => 'git://github.com/pat/ts-delayed-delta.git',
  :branch => 'master',
  :ref    => '839284f2f28b3f4caf3a3bf5ccde9a6d222c7f4d'
gem 'possibly', '~> 0.2.0'

gem 'delayed_job', "~> 4.1.1"
gem 'delayed_job_active_record', "~> 4.1.0"

gem 'web_translate_it', "~>2.1.8"
gem 'rails-i18n', '~> 4.0.8'
gem 'devise', "~>3.5.0"
gem 'devise-encryptable', '~> 0.2.0'
gem "omniauth-facebook", "~> 3.0.0"

# Dynamic form adds helpers that are needed, e.g. error_messages
gem 'dynamic_form', "~>1.1.4"
gem "truncate_html", "~>0.9.1"
gem 'money-rails', "~>1.3.0"

# The latest release (0.9.0) is not Rails 4 compatible
gem 'mercury-rails',
  git: 'git://github.com/jejacks0n/mercury.git',
  branch: 'master',
  ref: '1cc637b0bccea19085f824d2881c6513ed5ee8ae'

gem 'countries', '~> 1.2', '>= 1.2.2'
gem "mail_view", "~> 1.0.3"
gem 'statesman', '~> 1.3.1'
gem "premailer", "~> 1.8.2"
gem 'stringex', '~> 2.5.2'
gem 'paypal-sdk-permissions', '~> 1.96.4'
gem 'paypal-sdk-merchant', '~> 1.116.0'
gem 'airbrake', '~> 4.1.0'
gem 'librato-rails', "~> 0.11.1"

gem 'jwt', '~> 1.5.2'

# Use Oauth2 from current master, because the newest release
# uses old JWT version
# (This can be removed when oauth2 version > 1.1.0 is released)
gem 'oauth2',
  git: 'git://github.com/intridea/oauth2.git',
  branch: 'master',
  ref: 'e0006cb5099bf392f011eb5c49cbec4f893bbdba'

gem 'lograge', "~> 0.3.2"
gem 'public_suffix', "~> 1.5.1" # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

# Session store was removed from Rails 4
gem 'activerecord-session_store', "~> 1.0.0.pre"

# This gem was added to make Rails 3.2 -> 4 upgrade path easier.
# It adds `attr_protected` and `attr_accessor` methods to models.
# We should remove this gem before upgrading to Rails 5
gem 'protected_attributes', "~> 1.1.3"

# Remove Emojis.
# This will prevent MySQL from blowing up if someone's trying to insert Emojis
# This gem was inserted to make Rails 3->4 migration path easier. However,
# it's a hack and should be removed soon.
gem 'demoji', "~> 0.0.5"

gem 'faraday', '~> 0.9.1'
gem 'faraday_middleware', '~> 0.10.0'

gem "react_on_rails", "~> 6.0.5"

gem "css_parser", "~> 1.4.5"
gem 'sitemap_generator', "~> 5.1.0"

gem 'sitemap_generator', "~> 5.1.0"

# Use latest from master
#
# The latest master is needed because it contains the I18n.extend configuration
# See: https://github.com/fnando/i18n-js/pull/397
gem "i18n-js",
    git: "git://github.com/fnando/i18n-js.git",
    branch: "master",
    ref: "2ca6d31365bb41db21e373d126cac00d38d15144"

# A store scoped to the request object for caching
gem "request_store", "~> 1.3"

group :staging, :production do
  gem 'newrelic_rpm', '~> 3.9.1.236'
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'rubocop', '~> 0.37.2', require: false
  gem 'factory_girl_rails', "~> 4.4.1"
end

group :development, :staging do
  gem 'meta_request', '~> 0.3'
end

group :development do
  gem 'rb-fsevent', "~> 0.9.4", require: false
  gem 'guard-rspec', "~> 4.6.5", require: false
  gem 'annotate', "~> 2.6.5"
  gem 'zeus', '~> 0.15.4', require: false
  gem 'quiet_assets', "~> 1.1.0"
  gem 'better_errors', "~> 2.1.1"
  gem 'web-console', '~> 2.0'
  gem 'awesome_print', '~> 1.6.1'
end

group :test do
  gem 'capybara', '~> 2.6.2'
  gem "rspec-rails", "~>3.0"

  gem 'cucumber-rails', '~> 1.4.0', require: false # require: false is needed for cucumber-rails

  gem 'selenium-webdriver', '~> 2.45'

  # Launchy is needed by Capybara, e.g. save_and_open command needs Launchy to open a browser
  gem 'launchy', '~> 2.4', '>= 2.4.3'
  gem 'email_spec', '~> 1.6.0'
  gem 'timecop', '~> 0.6.3'
  gem 'rack-test', "~> 0.6.2"
  gem 'database_cleaner', '~> 1.1'
  gem 'connection_pool', "~> 0.9.3"

  # required for CircleCI automatic test balancing
  gem 'rspec_junit_formatter'
end

group :development, :test do
  gem 'pry-byebug'
end


gem 'therubyracer', '~> 0.12.2', platforms: :ruby
gem 'js-routes', '~> 1.2.5'

# Color utilities needed for landing page
gem 'color', '~> 1.8'
