require File.expand_path('../../../test/helper_modules', __FILE__)
include TestHelpers

RSpec.configure do |config|
  clean_db = -> {
    DatabaseCleaner.clean_with(:truncation)
    load_default_test_data_to_db_before_suite
    load_default_test_data_to_db_before_test
  }

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    if !defined?(Zeus)
      clean_db.call
    end
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :'no-transaction' => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each, :'no-transaction' => true) do
    clean_db.call
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
