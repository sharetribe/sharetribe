source 'http://rubygems.org'

ruby '2.1.2'

gem 'rails', '4.0.13'

# To use debugger
#gem 'ruby-debug'

gem 'coffee-rails', "~> 4.0.1"
gem 'uglifier'

gem 'sass-rails', '~> 4.0.0'
gem 'compass-rails', '~> 1.1'

# Requiring 'compass' gem directly is not normally needed,
# 'compass-rails' already does that.
#
# However, we want to have compass version which is at least 0.13,
# because it fixes a bug that caused compass helpers to override
# important Rails asset helpers
gem 'compass', '~> 0.13.alpha'

gem 'jquery-rails', '2.1.4'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
gem "passenger", "~> 5.0.18"

gem "mysql2"
gem 'haml'
gem 'sass', "  ~> 3.2.9"
gem 'rest-client', '>= 1.6.0'
gem 'paperclip', '~> 3.5.1'
gem 'delayed_paperclip'
gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'
gem "will_paginate", '~>3.0.5'
gem 'dalli'
gem "memcachier"
gem 'kgio', "~>2.8.0"
gem 'thinking-sphinx', '~> 3.1.1'
gem 'flying-sphinx', "~>1.2.0"
# Use patched v2.0.2
# Fixes issues: Create a new delayed delta job if there is an existing delta job which has failed
gem 'ts-delayed-delta', "~>2.0.2",
  :git    => 'git://github.com/pat/ts-delayed-delta.git',
  :branch => 'master',
  :ref    => '839284f2f28b3f4caf3a3bf5ccde9a6d222c7f4d'
gem 'possibly', '~> 0.2.0'

# Can not use version 4.0.3, since it stucks the rails server loading. The issue which caused this
# has been fixed for 4.0.4 https://github.com/collectiveidea/delayed_job/issues/697
# However, some tests break for 4.0.4, so keeping 4.0.2 for now
gem 'delayed_job', "~> 4.0.0", "<= 4.0.2"
gem 'delayed_job_active_record' # , "~> 4.0.0"
gem 'json', "~>1.8.0"
gem 'multi_json', "~>1.7.3" # 1.8.0 caused "invalid byte sequence in UTF-8" at heroku
gem 'web_translate_it'
gem 'rails-i18n'
gem 'devise', "~>3.0.0"
gem "devise-encryptable"
gem "omniauth-facebook", "~> 2.0.1"
gem 'spreadsheet'
gem 'rabl', '~> 0.7.10'
gem 'rake'
gem 'xpath'
gem 'dynamic_form'
gem "truncate_html"
gem 'money-rails'

# The latest release (0.9.0) is not Rails 4 compatible
gem 'mercury-rails',
  git: 'git://github.com/jejacks0n/mercury.git',
  branch: 'master',
  ref: '1cc637b0bccea19085f824d2881c6513ed5ee8ae'

gem 'fb-channel-file'
gem 'country_select', '~> 1.3.1'
gem 'braintree'
gem "mail_view", "~> 1.0.3"
gem 'statesman', '~> 0.5.0'
gem "premailer"
gem 'stringex', '~> 2.5.2'
gem 'paypal-sdk-permissions',
  :git    => 'git://github.com/paypal/permissions-sdk-ruby.git',
  :branch => 'master',
  :ref    => 'c0240bee9f94fe6338d67b4f754e1a11ce81619a'
gem 'paypal-sdk-merchant', '~> 1.116.0'
gem 'airbrake', '~>4.1.0'
gem 'cache_digests'
gem 'librato-rails'
gem 'jwt', '~> 1.5.1'

gem 'lograge'
gem 'public_suffix' # Needed currently to set GA hostname right, probably not
# needed anymore when GA script updated.

gem 'activerecord-session_store'

# This gem was added to make Rails 3.2 -> 4 upgrade path easier.
# It adds `attr_protected` and `attr_accessor` methods to models.
# We should remove this gem before upgrading to Rails 5
gem 'protected_attributes'

# Observers should be used only in test code. Do NOT use them in production
# code.
#
# Observers need to be placed in app/models and that's why they will get
# loaded also in a non-test environment. That's also the reason why we need
# to include the observers gem here and not in the :test group
gem 'rails-observers', '~> 0.1.2'

# Remove Emojis.
# This will prevent MySQL from blowing up if someone's trying to insert Emojis
# This gem was inserted to make Rails 3->4 migration path easier. However,
# it's a hack and should be removed soon.
gem 'demoji'

group :staging, :production do
  gem 'newrelic_rpm', '~> 3.9.1.236'
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'rubocop',          require: false
  gem 'factory_girl_rails'
end

group :development, :staging do
  gem 'meta_request', '~> 0.3'
end

group :development do
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
  gem 'rb-fsevent',       require: false
  gem 'guard-rspec',      require: false
  gem 'annotate'
  gem 'zeus', '0.15.1'
  gem 'i18n-tasks', '~> 0.6.2'
  gem 'quiet_assets'
  gem 'better_errors'
end

group :test do
  gem "rspec-rails", "~>2.99.0"
  gem 'capybara', "~> 2.2.1"
  gem 'cucumber-rails', '~> 1.4.0', :require => false
  gem 'cucumber'
  gem 'selenium-webdriver', '~> 2.45.0'
  gem 'launchy'
  gem 'ruby-prof'
  gem "pickle"
  gem 'email_spec', '~> 1.6.0'
  gem "parallel_tests", :group => :development
  gem 'timecop'
  gem 'rack-test'
  gem 'database_cleaner', '~> 1.1'
  gem 'connection_pool'
  gem 'coveralls', require: false
end

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'pry-stack_explorer'
end
