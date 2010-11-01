# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

require File.expand_path('../../test/helper_modules', __FILE__)
include TestHelpers

# def get_test_person_and_session(username="kassi_testperson1")
#   session = nil
#   test_person = nil
#   
#   #frist try loggin in to cos
#   begin
#     session = Session.create({:username => username, :password => "testi" })
#     #try to find in kassi database
#     test_person = Person.find(session.person_id)
# 
#   rescue RestClient::Request::Unauthorized => e
#     #if not found, create completely new
#     session = Session.create
#     test_person = Person.create({ :username => username, 
#                     :password => "testi", 
#                     :email => "#{username}@example.com"},
#                      session.headers["Cookie"])
#                      
#   rescue ActiveRecord::RecordNotFound  => e
#     test_person = Person.add_to_kassi_db(session.person_id)
#   end
#   return [test_person, session]
# end

def uploaded_file(filename, content_type)
  t = Tempfile.new(filename)
  t.binmode
  path = "#{fixture_path}/#{filename}"
  FileUtils.copy_file(path, t.path)
  (class << t; self; end).class_eval do
    alias local_path path
    define_method(:original_filename) {filename}
    define_method(:content_type) {content_type}
  end
  return t
end
