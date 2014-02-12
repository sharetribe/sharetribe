require 'rubygems'
require File.expand_path('../../../test/helper_modules', __FILE__)
include TestHelpers

require 'cucumber/rails'

# Hack to support transactional tests in cucumber
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil
 
  def self.connection
    @@shared_connection || retrieve_connection
  end
end
 
# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  puts "*** Cleaning database (don't do me too often. I'm slow)"
  DatabaseCleaner.clean_with(:truncation)
  load_default_test_data_to_db_before_suite
  load_default_test_data_to_db_before_test

  DatabaseCleaner.strategy = :transaction
  Cucumber::Rails::Database.javascript_strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# Clear cache for each run as caching is not planned to work when DB contents are changing and communities are removed
Rails.cache.clear

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end