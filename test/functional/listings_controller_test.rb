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
          :cookie => @cookie }
    assert_response :success
    assert_template 'show'
    assert_equal listings(:valid_listing), assigns(:listing)
  end
  
  def test_show_edit_form
    get :edit, 
        { :id => listings(:valid_listing).id }, 
        { :person_id => @test_person1.id, 
          :cookie => @cookie }
    assert_response :success
    assert_template 'edit'
    assert_equal listings(:valid_listing), assigns(:listing)
  end
  
  def test_edit_listing
    submit_with_person :update, { 
      :listing => { :title => "new_title", :content => "new_content", :good_thru => DateTime.now+(2), :language => ["fi", "swe"] },
      :id => listings(:valid_listing),
      :person_id => people(:one)
    }, :listing, :author_id, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :listing_updated
    assert_redirected_to listing_path(assigns(:listing))
  end
  
  def test_search_listings_view
    get :search
    assert_response :success
    assert_template 'search'
  end
  
  def test_search_listings
    search("", 0, false)
    search("tsikko", 1, true)
    search("*", 2, true)
    search("*", 3, false)
    search("otsikko", 1, true)
    search("*tsikk*", 2, false)
    search("*", 1, false, "sell")
  end
  
  # def test_mark_as_interesting_and_mark_as_not_interesting
  #   post :mark_as_interesting, :id => listings(:valid_listing).id
  #   assert_response :success
  #   assert_equal [ listings(:valid_listing) ], @test_person1.interesting_listings
  # end
  
  def test_show_close
    submit_with_person :close, { 
      :person_id => people(:one),
      :id => listings(:valid_listing)
    }, nil, nil, :get
    assert_response :success
    assert_template 'close'  
    assert_not_nil assigns(:listing)
    #assert_not_nil assigns(:person) # not needed anymore
    assert_not_nil assigns(:kassi_event)
    assert_not_nil assigns(:people)
  end
  
  def test_mark_as_closed
    return_to = listings_path 
    listing = listings(:valid_listing)
    submit_with_person :mark_as_closed, {
      :person_id => people(:one),
      :id => listing.id,
      :realized => "true",
      :kassi_event => {
        :eventable_id => listing.id,
        :eventable_type => "Listing",
        :comment_attributes => {
          :text_content => "Kommentti",
          :grade => 1,
          # :author_id => people(:one).id,
        },
        :participant_attributes => {
          people(:one).id => "requester",
        }
      }, 
      :person => {:name => "kassi_testperson2 (kassi_testperson2)"},
      :return_to => return_to
    }, :kassi_event, :receiver_id, :post
    
    assert_equal  :listing_closed, flash[:notice]
    assert_nil flash[:error]
    assert_redirected_to return_to
    assert_not_nil assigns(:kassi_event)
    kassi_event = assigns(:kassi_event)
    assert ! kassi_event.new_record?
    assert_equal "Kommentti", kassi_event.person_comments.first.text_content
    assert_equal 1, kassi_event.person_comments.first.grade
    assert_equal people(:one), kassi_event.requester
    assert_equal people(:two), kassi_event.buyer
    assert ! Listing.find(listing.id).open?, "Listing is still open after succesful close"
  end
     
  def test_close_listing_with_bad_name_parameters
    return_to = listings_path 
    listing = listings(:valid_listing)
    names_and_errors = [ {:name => "kassi_testperson1", :error => :cant_mark_yourself_as_realizer},
                         {:name => "yehruit34gnveu8g", :error => :no_match_with_given_name},
                         {:name => "", :error => :realizer_name_missing},
                         
                         #This is commented out because ASI only finds one person with "kassi", although there are 2
                         #{:name => "kassi", :error => :given_name_matched_more_than_one},
                       ]
    names_and_errors.each do |name_and_error|
      submit_with_person :mark_as_closed, {
         :person_id => people(:one),
         :id => listing.id,
         :realized => "true",
         :kassi_event => {
           :eventable_id => listing.id,
           :eventable_type => "Listing",
           :comment_attributes => {
             :text_content => "Kommentti",
             :grade => 1,
           },
           :participant_attributes => {
             people(:one).id => "requester",
           }
         }, 
         :person => {:name => name_and_error[:name]},
         :return_to => return_to
       }, :kassi_event, :receiver_id, :post
    
       assert_equal name_and_error[:error], flash[:error]
      assert Listing.find(listing.id).open?, "Listing was closed, but it should not!"
    end
  end
  
  def test_mark_as_closed_but_give_feedback_later
    return_to = listings_path 
    listing = listings(:valid_listing)
    submit_with_person :mark_as_closed, {
      :person_id => people(:one),
      :id => listing.id,
      :realized => "true",
      :kassi_event => {
        :eventable_id => listing.id,
        :eventable_type => "Listing",
        :comment_attributes => {
          #:text_content => "Kommentti",
          :grade => "later",
          # :author_id => people(:one).id,
        },
        :participant_attributes => {
          people(:one).id => "requester",
        }
      }, 
      :person => {:name => "kassi_testperson2 (kassi_testperson2)"},
      :return_to => return_to
    }, :kassi_event, :receiver_id, :post
    
    
    assert_nil flash[:error]
    assert_equal  :listing_closed, flash[:notice]
    assert_redirected_to return_to
    assert_not_nil assigns(:kassi_event)
    kassi_event = assigns(:kassi_event)
    assert ! kassi_event.new_record?
    assert_equal people(:one), kassi_event.requester
    assert_equal people(:two), kassi_event.buyer
    assert ! Listing.find(listing.id).open?, "Listing is still open after succesful close"
  end
  
  def test_show_comments_to_own_listings
    submit_with_person :comments, { 
      :person_id => people(:two)
    }, nil, nil, :get
    assert_response :success
    assert_template 'comments'
    assert_equal assigns(:comments).size, 1
  end
  
  def test_random_listing
    get :random
    assert_response :success, @response.body
    #assert_template 'show'
    #id = @response.headers["Location"][/listings\/(\d+)-/, 1]
    #shown_listing = Listing.find(id)
    #assert_redirected_to( shown_listing)
      
    assert assigns(:listing).open?, "random listing shower picked a closed listing!"
    
    # check that did not open a listing that should not be seen by everyone.
    assert_equal("everybody", assigns(:listing).visibility)
  end
  
  private
  
  def search(query, result_count, only_open, category = "")
    get :search, :q => query, :only_open => only_open, :category => { :category => category }
    assert_response :success
    assert_equal result_count, assigns(:listings).size
  end  
  
end
