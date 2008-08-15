require 'test_helper'
class SessionTest < ActiveSupport::TestCase

  def test_create_session
    s = Session.new( :app_password => "Xk4z5iZ", :app_name => "kassi" )
    resp = s.save
    resp = s.get("session")
    puts resp.inspect
    resp = s.destroy
  end
  
  def test_get_session
    #resp = Session.get("debug")
  end
  
  def test_destroy_session
    
  end
end
