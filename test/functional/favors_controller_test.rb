require 'test_helper'

class FavorsControllerTest < ActionController::TestCase

  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @cookie = @session1.cookie
  end

  def test_show_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:letters)
    assert_not_nil assigns(:favor_titles)
  end
  
  def test_show_favor
    get :show, :id => "hieronta"
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:title)
    assert_equal assigns(:favors), [ favors(:one) ]
  end
  
  def test_create_and_delete_favor
    submit_with_person :create, { 
      :favor => { :title => "TestTitle" }
    }, :favor, :owner_id
    assert_response :found, @response.body
    assert_not_nil flash[:notice]
    assert ! assigns(:favor).new_record?
    submit_with_person :destroy, {
      :id => assigns(:favor).id 
    }, :favor, :owner_id, :delete
    assert_redirected_to @test_person1
  end

  def test_edit_favor
    submit_with_person :update, { 
      :favor => { :title => "muutettu_vasara" },
      :id => favors(:one).id,
      :person_id => @test_person1.id
    }, :favor, :owner_id, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :favor_updated
  end

  def test_ask_for
    favor = favors(:two)
    submit_with_person :ask_for, {
      :person_id => people(:two).id,
      :id => favor.id
    }, nil, nil, :get
    assert_response :success
    assert_template 'ask_for'
    assert_not_nil assigns(:person)
    assert_not_nil assigns(:favor)
  end
  
  def test_thank_for
    submit_with_person :thank_for, { 
      :person_id => people(:one),
      :id => favors(:two).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'thank_for'  
    assert_not_nil assigns(:favor)
    assert_not_nil assigns(:person)
    assert_not_nil assigns(:kassi_event)
    assert_not_nil assigns(:people)
  end
  
  def test_mark_as_done
    favor = favors(:two)
    submit_with_person :mark_as_done, { 
      :person_id => people(:two),
      :id => favor.id,
      :kassi_event => {
        :realizer_id => people(:two),
        :eventable_id => favor.id,
        :eventable_type => "Favor",
        :comment => "Kommentti"
      }  
    }, :kassi_event, :receiver_id, :post
    assert_redirected_to people(:two)
    assert ! assigns(:kassi_event).new_record?
    assert_equal "Kommentti", assigns(:kassi_event).person_comments.first.text_content
  end

end
