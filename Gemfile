source 'https://rubygems.org'

ruby '2.6.5'

gem 'rails', '5.2.3'

gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 3.2.0'

gem 'sass-rails', '~> 5.0.6'
gem 'compass-rails', '~> 3.0.2'

gem 'jquery-rails', '~> 4.3.1'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem "passenger", '~> 6.0.1'

gem "mysql2", '0.4.10'
gem "bcrypt", '3.1.12'
gem 'haml', '~> 5.0.4'
gem 'sass', '~> 3.4.24'
gem 'rack-attack', '~> 6.0.0'
gem 'rest-client', '~> 2.0.2'

gem 'paperclip', '~> 6.0.0'
gem 'delayed_paperclip', '~> 3.0.1'

# Active Storage
gem 'image_processing', '~> 1.9.3'
gem 'mini_magick', '~> 4.9.5'

gem 'aws-sdk-s3', '~> 1'
gem 'aws-sdk-ses', '~> 1'
gem "will_paginate", '~> 3.1.7'
gem 'dalli', '~> 2.7.10'
gem "memcachier", '~> 0.0.2'
gem 'redis', '~> 4.1', '>= 4.1.1'
gem 'hiredis', '~> 0.6.3'
gem 'thinking-sphinx', '~> 3.3.0'
gem 'flying-sphinx', '~> 1.2.0'
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta', '2.1.0'
gem 'possibly', '~> 1.0.1'

gem 'delayed_job', '~> 4.1.3'
gem 'delayed_job_active_record', '~> 4.1.3'

gem 'web_translate_it', '~> 2.4.1'
gem 'rails-i18n', '~> 5.0.4'
gem 'devise', '>= 4.7.1'
gem 'devise-encryptable', '~> 0.2.0'
gem "omniauth-facebook", '~> 5.0.0'
gem "omniauth-google-oauth2", '>= 0.6.0'
gem "omniauth-linkedin-oauth2", '>= 1.0.0'
gem "omniauth-rails_csrf_protection", '~> 0.1.2'

# Dynamic form adds helpers that are needed, e.g. error_messages
gem 'dynamic_form', '~> 1.1.4'
gem "truncate_html", '~> 0.9.3'
gem 'money-rails', '~> 1.8.0'

# Modified version with Rails 5 fixes
gem 'mercury-rails',
  git: 'https://github.com/ithouse/mercury.git',
  branch: 'master',
  ref: '1a9d4ac5a0a5fd0d459ff1986f9f05e617415b16'

gem 'countries', '~> 2.0.8'
gem "mail_view", '~> 2.0.4'
gem 'statesman', '~> 7.1.0'
gem "premailer-rails", '~> 1.10.3'
gem "css_parser", '~> 1.7.0'
gem 'stringex', '~> 2.7.1'
gem 'paypal-sdk-permissions', '~> 1.96.4'
gem 'paypal-sdk-merchant', '~> 1.116.0'
gem 'airbrake', '~> 9.1.0'
gem 'stripe', '~> 4.9.0'

gem 'lograge', '~> 0.10.0'
gem 'public_suffix', '~> 2.0.5' # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

# Session store was removed from Rails 4
gem 'activerecord-session_store', '~> 1.1.3'

gem 'faraday', '~> 0.13.0'
gem 'faraday_middleware', '~> 0.11.0'
gem 'faraday-encoding', '~> 0.0.4'

gem "react_on_rails", ">= 11.3.0"

gem 'sitemap_generator', '~> 5.3.1'

gem "i18n-js", '~> 3.0.0'

# A store scoped to the request object for caching
gem "request_store", '~> 1.3.2'

# ActionMailer dependency that needs forced update for security patch
gem 'mail', '~> 2.6.6.rc1'

gem 'tzinfo-data', '~> 1.2017', '>= 1.2017.2'

group :staging, :production do
  gem 'newrelic_rpm', '~> 4.2.0.334'
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'rubocop', '~> 0.67.2', require: false
  gem 'factory_girl_rails', '~> 4.8.0'
end

group :development, :staging do
  gem 'meta_request', '~> 0.6.0'
end

group :development do
  gem 'rb-fsevent', '~> 0.9.8', require: false
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'listen', '~> 3.1.5'
  gem 'annotate', '~> 2.7.5'
  gem 'zeus', '~> 0.15.13', require: false
  gem 'web-console', '~> 3.7.0'
  gem 'awesome_print', '~> 1.7.0'
end

group :test do
  gem 'capybara', '~> 3.16.2'
  gem "rspec-rails", '~> 3.8.2'

  gem 'cucumber-rails', '~> 1.6.0', require: false # require: false is needed for cucumber-rails

  gem 'selenium-webdriver', '~> 3.141.0'

  # Launchy is needed by Capybara, e.g. save_and_open command needs Launchy to open a browser
  gem 'launchy', '~> 2.1'
  gem 'email_spec', '~> 2.1.1'
  gem 'timecop', '~> 0.8.1'
  gem 'database_cleaner', '~> 1.6.1'
  gem 'connection_pool', '~> 2.2.1'
  gem 'rails-controller-testing', '~> 1.0.2'

  # required for CircleCI automatic test balancing
  gem 'rspec_junit_formatter'

  gem 'fake_stripe', git: 'https://github.com/ithouse/fake_stripe.git', ref: 'd188f6ad796f498a3d6e9b6b087172d8c150f325'
  gem 'poltergeist'
  gem 'puma'
  gem 'webdrivers'
end

group :development, :test do
  gem 'pry-byebug'
end


gem 'mini_racer', platforms: :ruby
gem 'js-routes', '~> 1.3.3'

# Color utilities needed for landing page
gem 'color', '~> 1.8'

gem 'uuidtools', '~> 2.1.5'
gem 'transit-ruby', '~> 0.8.602'

# Markdown parser
gem 'redcarpet', '~> 3.4.0'

gem 'intercom'

gem 'twitter_cldr'
gem 'memoist'
gem 'biz'
gem 'ffi', '>= 1.9.25'
gem 'rubyzip', '~> 1.3.0'
gem 'bootsnap', require: false
gem "select2-rails"
gem "cocoon"
gem "fast-polylines"
