source 'https://rubygems.org'

ruby '3.2.2'

gem 'rails', '7.2.2.1'

gem 'coffee-rails', '~> 5.0.0'
gem 'uglifier', '~> 4.2.0'

gem 'sass-rails', '~> 5.0.6'
gem 'compass', git: 'https://github.com/Charly3X/compass.git'
gem 'compass-rails', '~> 4.0.0'

gem 'jquery-rails', '~> 4.4.0'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem 'passenger', '~> 6.0.27'

gem 'mysql2', '~> 0.5.6'
gem 'bcrypt', '~> 3.1.17'
gem 'haml', '~> 6.2.3'

gem 'sass', '3.4.24'
# gem 'compass', '0.12.2'

gem 'rack-attack', '~> 6.6.1'
gem 'rest-client', '~> 2.1.0'

gem 'kt-paperclip', '~> 7.2.2'
gem 'delayed_paperclip', '~> 3.0.1'

# Active Storage
gem 'image_processing', '~> 1.14.0'
gem 'mini_magick', '~> 4.11.0'

gem 'aws-sdk-s3', '~> 1.114.0'
gem 'aws-sdk-ses', '~> 1.47.0'
gem 'will_paginate', '~> 3.3.1'
gem 'redis', '~> 4.6.0'
gem 'hiredis', '~> 0.6.3'
gem 'thinking-sphinx', '~> 5.5'
gem 'flying-sphinx', '~> 2.2.0' # v3 - need faraday 2.0
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta', '2.1.0'
gem 'possibly', '~> 1.0.1'

gem 'delayed_job', '~> 4.1.3'
gem 'delayed_job_active_record', '~> 4.1.3'

gem 'web_translate_it', '~> 2.6.2'
gem 'rails-i18n', '~> 7.0'
gem 'devise', '~> 4.9.4'
gem 'devise-encryptable', '~> 0.2.0'
gem 'omniauth-facebook', '~> 9.0.0'
gem 'omniauth-google-oauth2', '~> 1.1.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'omniauth-linkedin-openid'

# Dynamic form adds helpers that are needed, e.g. error_messages
gem 'dynamic_form', '~> 1.1.5', git: 'https://github.com/Charly3X/dynamic_form.git'
gem 'truncate_html', '~> 0.9.3'
gem 'money-rails', '~> 1.15.0'

# Modified version with Rails 5 fixes
gem 'mercury-rails',
  git: 'https://github.com/ithouse/mercury.git',
  branch: 'master',
  ref: '1a9d4ac5a0a5fd0d459ff1986f9f05e617415b16'

gem 'countries', '~> 7.1.1'
gem 'mail_view', '~> 2.0.4'
gem 'statesman', '~> 12.1.0'
gem 'premailer-rails', '~> 1.11.1'
gem 'css_parser', '~> 1.11.0'
gem 'stringex', '~> 2.8.5'
gem 'paypal-sdk-permissions', '~> 1.96.4'
gem 'paypal-sdk-merchant', '~> 1.117.2'
gem 'airbrake', '~> 13.0.5'
gem 'stripe', '~> 5.55.0'

gem 'lograge', '~> 0.12.0'
gem 'public_suffix' # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

# Session store was removed from Rails 4
gem 'activerecord-session_store', '~> 2.0.0'

gem 'faraday', '~> 1.10.4'
gem 'faraday_middleware', '~> 1.2.0' # not support faraday 2.0.0
gem 'faraday-encoding', '~> 0.0.5'

gem 'react_on_rails', '13.0.2'

gem 'sitemap_generator', '~> 6.2.1'

gem 'i18n-js', '~> 3.9'

gem 'oj', '~> 3.16.10'

# A store scoped to the request object for caching
gem 'request_store', '~> 1.5.1'

# ActionMailer dependency that needs forced update for security patch
gem 'mail', '~> 2.8'

gem 'tzinfo-data', '~> 1.2022.1'

gem 'recaptcha', '~> 5.10.0'

gem 'simpleidn', '~> 0.2.1'

group :staging, :production do
  gem 'newrelic_rpm', '~> 9.17.0'
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'rubocop', '~> 1.74.0',  require: false
  gem 'rubocop-performance', '~> 1.24.0', require: false
  gem 'rubocop-rails', '~> 2.30.3', require: false
  gem 'factory_bot_rails'
  gem 'pry-byebug', '~> 3.10'
end

group :development do
  gem 'rb-fsevent', require: false
  gem 'listen', '~> 3.7.1'
  gem 'annotate', '~> 3.2.0'
  gem 'zeus', require: false
  gem 'awesome_print', '~> 1.9.2'
end

group :test do
  gem 'capybara', '~> 3.40.0'
  gem 'rspec-rails', '~> 7.0.0'

  gem 'cucumber-rails', '~> 3.1.1', require: false # require: false is needed for cucumber-rails
  gem 'cucumber', '9.2.1'

  gem 'selenium-webdriver', '~> 4.29.1'

  # Launchy is needed by Capybara, e.g. save_and_open command needs Launchy to open a browser
  gem 'launchy', '~> 3.1.1'
  gem 'email_spec', '~> 2.3.0'
  gem 'timecop', '~> 0.9.10'
  gem 'database_cleaner', '~> 2.1.0'
  gem 'connection_pool', '~> 2.2.5'
  gem 'rails-controller-testing', '~> 1.0.5'

  # required for CircleCI automatic test balancing
  gem 'rspec_junit_formatter', '~> 0.6.0'

  gem 'fake_stripe', git: 'https://github.com/ithouse/fake_stripe.git', ref: '56fe73dc420d161ecf9842739af7d857031ca1b2'
  gem 'poltergeist', '~> 1.18.1'
  gem 'puma', '~> 5.6.9'
  gem 'multi_test', '1.1.0'
end

gem 'mini_racer', '~> 0.6.0', platforms: :ruby
gem 'js-routes', '~> 2.2.3'
# Color utilities needed for landing page
gem 'color', '~> 1.8'
gem 'pry', '~> 0.14'
gem 'uuidtools', '~> 2.2.0'
gem 'transit-ruby', '0.9', git: 'https://github.com/Charly3X/transit-ruby.git'

# Markdown parser
gem 'redcarpet', '~> 3.6.0'

gem 'intercom', '~> 4.1.3'

gem 'twitter_cldr', '~> 6.11.3'
gem 'memoist', '~> 0.16.2'
gem 'biz', '~> 1.8.2'
gem 'ffi', '~> 1.15.5'
gem 'rubyzip', '~> 2.3.2'
gem 'bootsnap', '~> 1.18.4', require: false
gem 'select2-rails', '~> 4.0.13'
gem 'cocoon', '~> 1.2.15'
gem 'fast-polylines', '~> 2.2.2'
gem 'rb-inotify', '~> 0.10', require: false
gem 'psych', '< 4'
gem 'sorted_set'
