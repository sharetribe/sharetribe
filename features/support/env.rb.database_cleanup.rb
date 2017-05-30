#
# This file is named env.rb* for two reasons:
#
# 1) When cucumber option --dry-run is used, all the files that starts env.* are ignored and we don't need (or want)
#    this file to be loaded in dry mode. More: http://www.verious.com/tutorial/cucumbers-env-rb-dry-run-problems/
# 2) When cucumber option --dry-run is NOT used, we want this file to be loaded AFTER env.rb, so that Cucumber::Rails
#    is already defined

require 'rubygems'
require File.expand_path('../../../test/helper_modules', __FILE__)
include TestHelpers

require 'database_cleaner'

# Turn off all automatic database cleaning to gain full control of
# the cleanup process
Cucumber::Rails::World.use_transactional_tests = false
Cucumber::Rails::Database.autorun_database_cleaner = false

# Using two hacks here:
# - shared_connection hack shared the database connection
#   between Cucumber thread and the server thread
# - ConnectionPool tries its best to allow one thread at the time
#   to access the database to prevent race conditions
# - Add own mutex to isolate connection use further (ConnectionPool
#   fails sometimes)
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

module MutexLockedQuerying
  @@semaphore = Mutex.new

  def query(*)
    @@semaphore.synchronize { super }
  end
end

Mysql2::Client.prepend(MutexLockedQuerying)

def clean_db
  DatabaseCleaner.clean_with :deletion
  load_default_test_data_to_db_before_suite
  load_default_test_data_to_db_before_test
end

def set_strategy(strategy)
  DatabaseCleaner.strategy = strategy
  Cucumber::Rails::Database.javascript_strategy = strategy
end

if !defined?(Zeus)
  clean_db()
end
set_strategy(:transaction)

Before('@no-transaction') do
  set_strategy(:deletion)
end

Before('~@no-transaction') do
  set_strategy(:transaction)
  DatabaseCleaner.start
end

After('@no-transaction') do
  clean_db()
end

After('~@no-transaction') do
  DatabaseCleaner.clean
end
