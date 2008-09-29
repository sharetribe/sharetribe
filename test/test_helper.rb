ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  ##
  # returns a test person and a session-cookie where he's logged in. 
  # If the person doesn't exist already, creates him.
  
  def get_test_person_and_session
    session = nil
    test_person = nil
    
    #frist try loggin in to cos
    begin
      session = Session.create({:username => "kassi_testperson1", :password => "testi" })
      #try to find in kassi database
      test_person = Person.find(session.person_id)

    rescue ActiveResource::UnauthorizedAccess => e
      #if not found, create completely new
      session = Session.create
      test_person = Person.create({ :username => "kassi_testperson1", 
                      :password => "testi", 
                      :email => "kassi_testperson1@example.com"},
                       session.headers["Cookie"])
    rescue ActiveRecord::RecordNotFound  => e
      test_person = Person.add_to_kassi_db(session.person_id)
    end
    return [test_person, session]
  end
  
  def uploaded_file(filename, content_type)
    t = Tempfile.new(filename)
    t.binmode
    path = RAILS_ROOT + "/test/fixtures/" + filename
    FileUtils.copy_file(path, t.path)
    (class << t; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) {filename}
      define_method(:content_type) {content_type}
    end
    return t
  end
  
  def assert_redirect_when_not_logged_in
    assert_response :found
    assert_redirected_to new_session_path
    assert_equal flash[:warning], :you_must_login_to_do_this
  end
  
  def post_with_author(action, parameters = nil, parameter_type = :listing)
    current_user, session = get_test_person_and_session
    parameters[parameter_type].merge!({:author_id => current_user.id })
    post action, parameters, :person_id => current_user.id
  end
      
end
