require 'test_helper'

class ListingsControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @cookie = @session1.cookie
    @listing_params =  { :listing => {
      :category => "sell",
      :title => "Myydään alastomia oravoita",
      :content => "Title says it all.",
      :good_thru => DateTime.now+(2),
      :times_viewed => 32,
      :status => "open",
      :language_fi => 1,
      :language_swe => 1
    }}
  end
  
  def teardown
    @session1.destroy
    @session2.destroy
  end
  
  def test_show_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:listings)
  end
  
  def test_show_new
    # When not logged in 
    get :new
    assert_redirect_when_not_logged_in
    
    # When logged in
    submit_with_person :new, {}, nil, nil, :get
    assert_response :success
    assert_template 'new'  
    assert_not_nil assigns(:listing)
  end

  def test_add_and_delete_valid_listing
    image = uploaded_file("Bison_skull_pile.png", "image/png")
    @listing_params[:listing].merge!(:image_file => image)
    
    submit_with_person :create, @listing_params
    assert_response :found, @response.body
    assert_redirected_to listing_path(assigns(:listing))
    id = assigns(:listing).id
    assert ! assigns(:listing).new_record?
    assert_not_nil flash[:notice]
    assert Listing.find(id)
    assert File.exists?("tmp/test_images/" + id.to_s + ".png")
    
    # Delete just created listing
    test_person2, session2 = get_test_person_and_session #new session for same user 
    delete :destroy, {:id => id}, {:cookie => session2.cookie}
    # Image file must be deleted if listing is deleted
    assert !File.exists?("tmp/test_images/" + id.to_s + ".png")
    session2.destroy
  end
  
  def test_add_invalid_listing
    submit_with_person :create, :listing => {
    }
    assert assigns(:listing).errors.on(:category)
    assert assigns(:listing).errors.on(:title)
    assert assigns(:listing).errors.on(:content)
    assert assigns(:listing).errors.on(:good_thru)
    assert assigns(:listing).errors.on(:status)
    assert assigns(:listing).errors.on(:language)
  end
  
  def test_add_invalid_image_to_listing
    image = uploaded_file("i_am_not_image.txt", "text/plain")
    @listing_params[:listing].merge!(:image_file => image)
    
    submit_with_person :create, @listing_params
    assert assigns(:listing).errors.on(:image_file)
  end
  
  def test_show_listing
    get :show, 
        { :id => listings(:valid_listing).id }, 
        { :person_id => @test_person1.id, 
          :cookie => @cookie, 
          :ids => [listings(:valid_listing).id, listings(:another_valid_listing).id] }
    assert_response :success
    assert_template 'show'
    assert_equal listings(:valid_listing), assigns(:listing)
  end
  
  def test_search_listings_view
    get :search
    assert_response :success
    assert_template 'search'
  end
  
  def test_search_listings
    search("tsikko", 0, true)
    search("*", 2, true)
    search("*", 3, false)
    search("otsikko", 1, true)
    search("*tsikk*", 2, false)
  end
  
  # def test_mark_as_interesting_and_mark_as_not_interesting
  #   post :mark_as_interesting, :id => listings(:valid_listing).id
  #   assert_response :success
  #   assert_equal [ listings(:valid_listing) ], @test_person1.interesting_listings
  # end  
  
  def test_reply
    listing = listings(:third_valid_listing)
    submit_with_person :reply, {
      :id => listing.id
    }, nil, nil, :get
    assert_response :success
    assert_template 'reply'
    assert_not_nil assigns(:listing)
    assert_not_nil assigns(:message)
  end
  
  def test_show_close
    submit_with_person :close, { 
      :person_id => people(:one),
      :id => listings(:valid_listing)
    }, nil, nil, :get
    assert_response :success
    assert_template 'close'  
    assert_not_nil assigns(:listing)
    assert_not_nil assigns(:person)
    assert_not_nil assigns(:kassi_event)
    assert_not_nil assigns(:people)
  end
  
  def test_mark_as_closed
    listing = listings(:valid_listing)
    submit_with_person :mark_as_closed, {
      :person_id => people(:one),
      :id => listing.id,
      :kassi_event => {
        :realizer_id => people(:two),
        :eventable_id => listing.id,
        :eventable_type => "Listing",
        :comment => "Kommentti"
      }  
    }, :kassi_event, :receiver_id, :post
    assert_redirected_to person_listings_path(people(:one))
    assert ! assigns(:kassi_event).new_record?
    assert_equal "Kommentti", assigns(:kassi_event).person_comments.first.text_content
  end
  
  private
  
  def search(query, result_count, only_open)
    get :search, :q => query, :only_open => only_open
    assert_response :success
    assert_equal result_count, assigns(:listings).size
  end  
  
end
