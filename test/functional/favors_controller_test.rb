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
    assert_not_nil assigns(:favor_title_hash)
  end
  
  def test_show_favor
    get :show, :id => "hieronta"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_equal assigns(:favors), [ favors(:one) ]
  end
  
  def test_show_favor_with_difficult_characters
    get :show, :id => "Ämyrien laina'us/roudaus (12.00-14.00) *lol* + web 2.0-opas (fi/en)"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:favors)
    assert_equal assigns(:favors), [ favors(:difficult) ]
  end
  
  def test_create_and_delete_favor
    submit_with_person :create, { 
      :favor => { :title => "TestTitle" }
    }, :favor, :owner_id
    assert_response :success, @response.body
    assert_not_nil flash[:notice]
    assert ! assigns(:favor).new_record?
    submit_with_person :destroy, {
      :id => assigns(:favor).id 
    }, :favor, :owner_id, :delete
    assert_equal "disabled", assigns(:favor).status
  end

  def test_create_favor_with_title_that_already_exists 
    submit_with_person :create, { 
      :favor => { :title => "hieronta" }
    }, :favor, :owner_id
    assert assigns(:favor).errors.on(:title)
  end
  
  def test_recover_disabled_favor 
    submit_with_person :create, { 
      :favor => { :title => "nördäys" }
    }, :favor, :owner_id
    assert_response :success, @response.body
    assert_nil assigns(:favor).id
    assert_equal "enabled", favors(:three).status
  end

  def test_edit_favor
    submit_with_person :update, { 
      :favor => { 
        :title => "thaihieronta",
        :visibility => "everybody" 
      },
      :id => favors(:one).id,
      :person_id => @test_person1.id
    }, :favor, :owner_id, :put
    assert_response :success, @response.body
    assert_equal flash[:notice], :favor_updated
    assert_equal "thaihieronta", assigns(:favor).title
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
  end
  
  def test_mark_as_done
    return_to = people_path 
    favor = favors(:two)
    submit_with_person :mark_as_done, { 
      :person_id => people(:two),
      :id => favor.id,
      :kassi_event => {
        :eventable_id => favor.id,
        :eventable_type => "Favor",
        :comment_attributes => {
          :text_content => "Kommentti",
          :grade => 0.5,
          :author_id => people(:one).id,
          :target_person_id => people(:two).id
        },
        :participant_attributes => {
          people(:one).id => "requester",
          people(:two).id => "provider"
        }
      },
      :return_to => return_to 
    }, :kassi_event, :receiver_id, :post
    assert_redirected_to return_to
    assert_equal flash[:notice], :thanks_for_favor_sent
    kassi_event = assigns(:kassi_event)
    assert ! kassi_event.new_record?
    assert_equal "Kommentti", kassi_event.person_comments.first.text_content
    assert_equal 0.5, kassi_event.person_comments.first.grade
    assert_equal people(:one), kassi_event.requester
    assert_equal people(:two), kassi_event.provider
  end
  
  def test_search_favors
    search("dsfds", 0)
    search("*", 3)
  end
  
  private
  
  def search(query, result_count)
    get :search, :q => query
    assert_response :success
    assert_equal result_count, assigns(:favors).size
  end

end
