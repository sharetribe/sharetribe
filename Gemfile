source 'https://rubygems.org'

ruby '2.7.5'

gem 'rails', '6.1.6.1'

gem 'coffee-rails'
gem 'uglifier'

gem 'sass-rails', '~> 5.0.6'
gem 'compass-rails', '~> 3.0.0'

gem 'jquery-rails', '~> 4.3.1'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem "passenger", '~> 6.0.14'

gem "mysql2"
gem "bcrypt"
gem 'haml'

gem 'sass', '3.4.24'
# gem 'compass', '0.12.2'

# gem 'sass', '3.4.25'
gem 'rack-attack'
gem 'rest-client'

gem 'paperclip'
gem 'delayed_paperclip'

# Active Storage
gem 'image_processing'
gem 'mini_magick'

gem 'aws-sdk-s3'
gem 'aws-sdk-ses'
gem "will_paginate"
gem 'dalli', '~> 2.7.10'
gem "memcachier"
gem 'redis'
gem 'hiredis'
gem 'thinking-sphinx', '~> 3.3.0'
gem 'flying-sphinx', '~> 1.2.0'
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta', '2.1.0'
gem 'possibly'

gem 'delayed_job', '~> 4.1.3'
gem 'delayed_job_active_record', '~> 4.1.3'

gem 'web_translate_it'
gem 'rails-i18n', '~> 6.0'
gem 'devise'
gem 'devise-encryptable'
gem "omniauth-facebook"
gem "omniauth-google-oauth2"
gem "omniauth-linkedin-oauth2"
gem "omniauth-rails_csrf_protection"

# Dynamic form adds helpers that are needed, e.g. error_messages
gem 'dynamic_form'
gem "truncate_html"
gem 'money-rails'

# Modified version with Rails 5 fixes
gem 'mercury-rails',
  git: 'https://github.com/ithouse/mercury.git',
  branch: 'master',
  ref: '1a9d4ac5a0a5fd0d459ff1986f9f05e617415b16'

gem 'countries', require: 'countries/global'
gem "mail_view"
gem 'statesman'
gem "premailer-rails"
gem "css_parser"
gem 'stringex'
gem 'paypal-sdk-permissions'
gem 'paypal-sdk-merchant'
gem 'airbrake', '~> 10.0.4'
gem 'stripe'

gem 'lograge'
gem 'public_suffix' # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

# Session store was removed from Rails 4
gem 'activerecord-session_store'

gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-encoding'

gem "react_on_rails", ">= 11.3.0"

gem 'sitemap_generator'

gem "i18n-js", '~> 3.9'

gem 'oj', '~> 3.13'

# A store scoped to the request object for caching
gem "request_store"

# ActionMailer dependency that needs forced update for security patch
gem 'mail'

gem 'tzinfo-data'

gem 'recaptcha'

gem 'simpleidn'

group :staging, :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'rubocop',  require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'factory_girl_rails'
end

group :development, :staging do
  # gem 'meta_request'
end

group :development do
  gem 'rb-fsevent', require: false
  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'annotate'
  gem 'zeus', require: false
  # gem 'web-console'
  gem 'awesome_print'
end

group :test do
  gem 'capybara'
  gem "rspec-rails"

  gem 'cucumber-rails', '~> 2.2.0', require: false # require: false is needed for cucumber-rails
  gem 'cucumber', '3.1.2'

  gem 'selenium-webdriver'

  # Launchy is needed by Capybara, e.g. save_and_open command needs Launchy to open a browser
  gem 'launchy'
  gem 'email_spec'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'connection_pool'
  gem 'rails-controller-testing'

  # required for CircleCI automatic test balancing
  gem 'rspec_junit_formatter'

  gem 'fake_stripe', git: 'https://github.com/ithouse/fake_stripe.git', ref: '56fe73dc420d161ecf9842739af7d857031ca1b2'
  gem 'poltergeist'
  gem 'puma'
  gem 'webdrivers'
  gem 'multi_test', '0.1.2'
end

group :development, :test do
  gem 'pry-byebug'
end


# gem 'mini_racer', '~> 0.6.0', platforms: :ruby
gem 'js-routes'
# Color utilities needed for landing page
gem 'color'

gem 'uuidtools'
gem 'transit-ruby', git: 'https://github.com/Charly3X/transit-ruby.git'

# Markdown parser
gem 'redcarpet'

gem 'intercom'

gem 'twitter_cldr'
gem 'memoist'
gem 'biz'
gem 'ffi'
gem 'rubyzip'
gem 'bootsnap', '~> 1.4.5', require: false
gem "select2-rails"
gem "cocoon"
gem "fast-polylines"
gem "codemirror-rails"
gem 'rb-inotify', '~> 0.10'
