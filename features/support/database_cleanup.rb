require 'rubygems'
require File.expand_path('../../../test/helper_modules', __FILE__)
include TestHelpers

require 'cucumber/rails'
require 'database_cleaner'

# Turn off all automatic database cleaning to gain full control of
# the cleanup process
Cucumber::Rails::World.use_transactional_fixtures = false
Cucumber::Rails::Database.autorun_database_cleaner = false

class ManualDatabaseCleaner
  @cumulative

  def initialize
    @cumulative = 0
  end

  # Clean db and load initial seed data
  def clean_db
    beginning_time = Time.now
    DatabaseCleaner.clean_with :deletion
    load_default_test_data_to_db_before_suite
    load_default_test_data_to_db_before_test
    time_elapsed = (Time.now - beginning_time)*1000
    @cumulative += time_elapsed
    puts "*** Loading test seed data. Time elapsed: #{time_elapsed} ms, cumulative: #{@cumulative} ms"
  end
end

def set_strategy(strategy)
  DatabaseCleaner.strategy = strategy
  Cucumber::Rails::Database.javascript_strategy = strategy
end

# Run on startup
cleaner = ManualDatabaseCleaner.new()
cleaner.clean_db()
set_strategy(:transaction)

Before('@no-transaction') do
  puts "*** Warning! Running test without transaction (this is little slower)"
  set_strategy(:deletion)
end

Before('~@no-transaction') do
  set_strategy(:transaction)
  DatabaseCleaner.start
end

After('@no-transaction') do
  cleaner.clean_db()
end

After('~@no-transaction') do
  DatabaseCleaner.clean
end