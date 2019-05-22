require 'cucumber/rspec/doubles'
require File.expand_path('../../test/helper_modules', __dir__)

World(TestHelpers)
World(Rack::Test::Methods)
