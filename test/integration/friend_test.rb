require 'test_helper'

class PeopleTest < ActionController::IntegrationTest
    
  fixtures :people
  fixtures :items

  # Tests friend functionality
  def test_add_and_remove_friend
    
    # Log in as person 1
    post "/session", { :username => "kassi_testperson1", :password => "testi"}
    assert_response :found
    
    # Make sure that there is no active or pending friendships
    post "/people/#{people(:one).id}/requests/#{people(:two).id}/cancel"
    post "/people/#{people(:one).id}/requests/#{people(:two).id}/reject"
    delete "/people/#{people(:one).id}/friends/#{people(:two).id}"
    
    # There should be no friends in the friend view
    get "/people/#{people(:one).id}/friends"
    assert_response :success
    assert_template 'index'
    assert_equal 0, assigns(:friends).size
    
    # Request person 2 as a friend
    post "/people/#{people(:two).id}/friends"
    assert_response :success
    assert_equal :friend_requested, flash[:notice]
    
    # Check that person 2 has received an email notification
    mail = UserMailer.create_notification_of_new_friend_request(people(:one), people(:two))
    assert_equal(KASSI_MAIL_FROM_ADDRESS, mail.from.first)
    assert_equal(people(:one).name + ' on lisännyt sinut kaveriksi Kassissa', mail.subject)
    assert mail.to, "Could not get email address for recipient #{people(:two).name}"
    assert_equal(people(:two).email, mail.to.first)
    
    # Log out
    delete "/session"
    assert_response :found
    
    # Log in as person 2
    post "/session", { :username => "kassi_testperson2", :password => "testi"}
    assert_response :found
    
    # There should be no friends in the friend view
    get "/people/#{people(:two).id}/friends"
    assert_response :success
    assert_template 'index'
    assert_equal 0, assigns(:friends).size
    
    # The item of person 1 should not yet be visible (because it is for friends only)
    get "/items"
    assert_response :success, @response.body
    assert( ! @response.body.match(items(:friends_only).title), "Friends-only item should not be visible")
    
    # There should be one new request from person 1
    get "/people/#{people(:two).id}/requests"
    assert_response :success
    assert_template 'index'
    assert_equal 1, assigns(:requesters).size
    assert_equal people(:one), assigns(:requesters).first
    
    # Accept friend request from person 1
    post "/people/#{people(:two).id}/requests/#{assigns(:requesters).first.id}/accept"
    assert_response :success
    assert_equal [:friend_request_accepted, people(:one).name, person_path(people(:one))], flash[:notice]
    
    # There should be no more requests
    get "/people/#{people(:two).id}/requests"
    assert_response :success
    assert_template 'index'
    assert_equal 0, assigns(:requesters).size
    
    #CacheHelper.update_items_last_changed
    
    # The item of person 1 should now be visible (because it is for friends only)
    get "/items"
    assert_response :success, @response.body
    assert(@response.body.match(items(:friends_only).title), "Friends-only item should be visible")
    
    # Person 1 should now be visible in the friend view
    get "/people/#{people(:two).id}/friends"
    assert_response :success
    assert_template 'index'
    assert_equal 1, assigns(:friends).size
    assert_equal people(:one), assigns(:friends).first
    
    #puts "1"
    
    # Remove person 1 from friends
    delete "/people/#{people(:two).id}/friends/#{assigns(:friends).first.id}"
    assert_response :success
    assert_equal :friend_removed, flash[:notice]
    
    
    # There should be no friends in the friend view
    get "/people/#{people(:two).id}/friends"
    assert_response :success
    assert_template 'index'
    assert_equal 0, assigns(:friends).size
    
    #puts "2"
    #CacheHelper.update_items_last_changed
    
    # The item of person 1 should not be visible anymore (because it is for friends only)
    get "/items"
    assert_response :success, @response.body
    assert( ! @response.body.match(items(:friends_only).title), "Friends-only item should not be visible")
    
    # Request person 1 as a friend
    post "/people/#{people(:one).id}/friends"
    assert_response :success
    assert_equal :friend_requested, flash[:notice]
    
    # Cancel friend request
    post "/people/#{people(:two).id}/requests/#{people(:one).id}/cancel"
    assert_response :success
    assert_equal :friend_request_canceled, flash[:notice]
    
    # Request person 1 as a friend
    post "/people/#{people(:one).id}/friends"
    assert_response :success
    assert_equal :friend_requested, flash[:notice]
    
    # Log out
    delete "/session"
    assert_response :found
    
    # Log in as person 1
    post "/session", { :username => "kassi_testperson1", :password => "testi"}
    assert_response :found
    
    # There should be one new request from person 2
    get "/people/#{people(:one).id}/requests"
    assert_response :success
    assert_template 'index'
    assert_equal 1, assigns(:requesters).size
    assert_equal people(:two), assigns(:requesters).first
    
    # Reject friend request and check that there are no more requests
    post "/people/#{people(:one).id}/requests/#{people(:two).id}/reject", {}, { :referer => person_requests_path(people(:one)) }
    assert_equal :friend_request_rejected, flash[:notice]
    assert_redirected_to person_requests_path(people(:one))
    follow_redirect!
    assert_template 'index'
    assert_equal 0, assigns(:requesters).size
    
    # Request person 2 as a friend
    post "/people/#{people(:two).id}/friends"
    assert_response :success
    assert_equal :friend_requested, flash[:notice]
    
    # Log out
    delete "/session"
    assert_response :found
    
    # Log in as person 2
    post "/session", { :username => "kassi_testperson2", :password => "testi"}
    assert_response :found
    
    # There should be one new request from person 1
    get "/people/#{people(:two).id}/requests"
    assert_response :success
    assert_template 'index'
    assert_equal 1, assigns(:requesters).size
    assert_equal people(:one), assigns(:requesters).first

    # Accept friend request from person 1 using the buttons in 
    # request view and check that there are no more requests
    post "/people/#{people(:two).id}/requests/#{assigns(:requesters).first.id}/accept_redirect", {}, { :referer => person_requests_path(people(:two)) }
    assert_equal [:friend_request_accepted, people(:one).name, person_path(people(:one))], flash[:notice]
    assert_redirected_to person_requests_path(people(:two))
    follow_redirect!
    assert_template 'index'
    assert_equal 0, assigns(:requesters).size
    
    # Person 1 should now be visible in the friend view
    get "/people/#{people(:two).id}/friends"
    assert_response :success
    assert_template 'index'
    assert_equal 1, assigns(:friends).size
    assert_equal people(:one), assigns(:friends).first
    
    # Remove person 1 from friends
    delete "/people/#{people(:two).id}/friends/#{assigns(:friends).first.id}"
    assert_response :success
    assert_equal :friend_removed, flash[:notice]
    
  end
  
end  