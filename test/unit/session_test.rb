require 'test_helper'
class SessionTest < ActiveSupport::TestCase

  def test_create_get_and_destroy_session
    s = Session.create
    resp = s.check
    assert_not_nil( resp["app_id"])
    assert_nil(resp["user_id"])
    resp = s.destroy
    assert_equal(resp.class, Net::HTTPOK)
  end

  def test_create_user_session
    s = Session.create( {:username => "kassi_testperson1", :password => "testi"})
    resp = s.get("")
    assert_not_nil(resp["app_id"])
    assert_not_nil(resp["user_id"])
    resp = s.destroy
  end
  
  def test_multiple_sessions
    s1 = Session.create( {:username => "kassi_testperson1", :password => "testi"})
    s2 = Session.create( {:username => "kassi_testperson2", :password => "testi"})
    resp1 = s1.check
    resp2 = s2.check
    assert_not_nil(resp1["user_id"])
    assert_not_nil(resp2["user_id"])
    assert_not_equal(resp1["user_id"], resp2["user_id"])
    s1.destroy
    s2.destroy
  end
  
  def test_getting_session_by_cookie
    @test_person, @session = get_test_person_and_session
    cookie = @session.cookie
    other_session = Session.get_by_cookie(cookie)
    assert_equal(@session.person_id, other_session.person_id)
    @session.destroy
  end
end
