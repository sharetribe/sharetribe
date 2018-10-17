source 'http://rubygems.org'

ruby '2.3.4'

gem 'rails', '5.1.1'

gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 3.2.0'

gem 'sass-rails', '~> 5.0.6'
gem 'compass-rails', '~> 3.0.2'

gem 'jquery-rails', '~> 4.3.1'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem "passenger", '~> 5.1.4'

gem "mysql2", '0.4.10'
gem "bcrypt", '3.1.12'
gem 'haml', '~> 5.0.1'
gem 'sass', '~> 3.4.24'
gem 'rack-attack', '~> 5.0.1'
gem 'rest-client', '~> 2.0.2'

gem 'paperclip', '~> 5.2.1'
gem 'delayed_paperclip', '~> 3.0.1'

gem 'aws-sdk', '~> 2.9.25'
gem "will_paginate", '~> 3.1.5'
gem 'dalli', '~> 2.7.6'
gem "memcachier", '~> 0.0.2'
gem 'readthis', '~> 2.0.2'
gem 'hiredis', '~> 0.6.1'
gem 'thinking-sphinx', '~> 3.3.0'
gem 'flying-sphinx', '~> 1.2.0'
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta',
  :git    => 'https://github.com/pat/ts-delayed-delta.git',
  :branch => 'master',
  :ref    => '0aef2195f3acc1da048f18bc0191c90538565705'
gem 'possibly', '~> 1.0.1'

gem 'delayed_job', '~> 4.1.3'
gem 'delayed_job_active_record', '~> 4.1.2'

gem 'web_translate_it', '~> 2.4.1'
gem 'rails-i18n', '~> 5.0.4'
gem 'devise', '~> 4.3.0'
gem 'devise-encryptable', '~> 0.2.0'
gem "omniauth-facebook", '~> 4.0.0'

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
gem 'statesman', '~> 2.0.1'
gem "premailer", '~> 1.10.4'
gem 'stringex', '~> 2.7.1'
gem 'paypal-sdk-permissions', '~> 1.96.4'
gem 'paypal-sdk-merchant', '~> 1.116.0'
gem 'airbrake', '~> 6.1.2'
gem 'stripe', '~> 3.0.0'

gem 'jwt', '~> 1.5.6'

gem 'oauth2', '~> 1.3.1'

gem 'lograge', '~> 0.5.1'
gem 'public_suffix', '~> 2.0.5' # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

# Session store was removed from Rails 4
gem 'activerecord-session_store', '~> 1.1.0'

gem 'faraday', '~> 0.11.0'
gem 'faraday_middleware', '~> 0.11.0'
gem 'faraday-encoding', '~> 0.0.4'

gem "react_on_rails", "~>6.9.0"

gem "css_parser", '~> 1.5.0'
gem 'sitemap_generator', '~> 5.3.1'

gem "i18n-js", '~> 3.0.0'

# A store scoped to the request object for caching
gem "request_store", '~> 1.3.2'

# ActionMailer dependency that needs forced update for security patch
gem 'mail', '~> 2.6.6.rc1'

group :staging, :production do
  gem 'newrelic_rpm', '~> 4.2.0.334'
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'rubocop', '~> 0.49.1', require: false
  gem 'factory_girl_rails', '~> 4.8.0'
end

group :development, :staging do
  gem 'meta_request', '~> 0.4.3'
end

group :development do
  gem 'rb-fsevent', '~> 0.9.8', require: false
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'listen', '~> 3.1.5'
  gem 'annotate', '~> 2.7.1'
  gem 'zeus', '~> 0.15.13', require: false
  gem 'better_errors', '~> 2.1.1'
  gem 'web-console', '~> 3.5.1'
  gem 'awesome_print', '~> 1.7.0'
  gem 'binding_of_caller'
end

group :test do
  gem 'capybara', '~> 2.6.2'
  gem "rspec-rails", '~> 3.6.0'

  gem 'cucumber-rails', '~> 1.5.0', require: false # require: false is needed for cucumber-rails

  gem 'selenium-webdriver', '~> 2.53.4'

  # Launchy is needed by Capybara, e.g. save_and_open command needs Launchy to open a browser
  gem 'launchy', '~> 2.1'
  gem 'email_spec', '~> 2.1.1'
  gem 'timecop', '~> 0.8.1'
  gem 'rack-test', '~> 0.6.3'
  gem 'database_cleaner', '~> 1.6.1'
  gem 'connection_pool', '~> 2.2.1'
  gem 'rails-controller-testing', '~> 1.0.2'

  # required for CircleCI automatic test balancing
  gem 'rspec_junit_formatter'

  gem 'fake_stripe', git: 'https://github.com/ithouse/fake_stripe.git', ref: '6848daab104333b2c0c493ab069731d4a0b87f6f'
end

group :development, :test do
  gem 'pry-byebug'
end


gem 'therubyracer', '~> 0.12.3', platforms: :ruby
gem 'js-routes', '~> 1.3.3'

# Color utilities needed for landing page
gem 'color', '~> 1.8'

gem 'uuidtools', '~> 2.1.5'
gem 'transit-ruby', '~> 0.8.1'

# Markdown parser
gem 'redcarpet', '~> 3.4.0'

gem 'intercom'

gem 'twitter_cldr'
gem 'memoist'
gem 'biz'
