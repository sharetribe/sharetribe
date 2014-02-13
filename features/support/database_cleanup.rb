require 'rubygems'
require File.expand_path('../../../test/helper_modules', __FILE__)
include TestHelpers

require 'cucumber/rails'
require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

$cumulative = 0

Before do
  beginning_time = Time.now
  load_default_test_data_to_db_before_suite
  load_default_test_data_to_db_before_test
  time_elapsed = (Time.now - beginning_time)*1000
  $cumulative = $cumulative + time_elapsed
  puts "*** Loading default test values to database. Time elapsed: #{time_elapsed} ms)"
  puts "*** Cumulative: #{$cumulative} ms"
end

Before('@no-transaction') do
  puts "*** Warning! Running test without transaction"
  Cucumber::Rails::Database.javascript_strategy = :truncation
end

Before('~@no-transaction') do
  Cucumber::Rails::Database.javascript_strategy = :transaction
end

