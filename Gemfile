source 'http://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.9'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Gems used only for assets and not required  
# in production environments by default.  
group :assets do  
  gem 'sass-rails', "  ~> 3.2.5"
  gem 'coffee-rails', "~> 3.2.2"
  gem 'uglifier'  
end  
  
gem 'jquery-rails'

# Bundle the extra gems:

# gem 'heroku' install the Heroku toolbelt (https://toolbelt.heroku.com/) instead (as gem had some problems)
#gem 'thin'
gem 'unicorn'

gem "mysql2"
gem 'haml'
gem 'sass'
gem 'database_cleaner'
gem 'rest-client', '>= 1.6.0'
gem 'acts-as-taggable-on'
gem 'paperclip'
gem 'aws-sdk'
gem "will_paginate"
gem 'whenever'
gem 'newrelic_rpm'
gem 'memcache-client', ">= 1.8.5"
gem 'thinking-sphinx', :require => 'thinking_sphinx'
gem 'flying-sphinx'
gem 'recaptcha'
gem "airbrake"
gem 'passenger'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'json'
gem 'russian'
gem 'web_translate_it'
gem 'postmark-rails'
gem 'rails-i18n'
gem 'devise'
gem "devise-encryptable"
gem "omniauth-facebook"
gem 'spreadsheet'
gem 'rabl'
gem 'rake'
gem 'xpath'
gem 'dynamic_form'
gem "rspec-rails"
gem "truncate_html"

group :test do

  gem 'capybara', "1.1.3" # because version 2 causes too many unambiguous matches with current test suite
  # TODO: upgrade with changes from: http://techblog.fundinggates.com/blog/2012/08/capybara-2-0-upgrade-guide/
  gem 'cucumber-rails', :require => false
  gem 'cucumber' 
  gem 'selenium-webdriver'
  gem 'launchy'
  gem 'ruby-prof'
  gem 'factory_girl_rails'
  gem "pickle"
end

