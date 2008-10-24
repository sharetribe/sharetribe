require 'test_helper'

class Admin::FeedbacksControllerTest < ActionController::TestCase
  
  def setup
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  def teardown
    @session.destroy
  end
  
end
