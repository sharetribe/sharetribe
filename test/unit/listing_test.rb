require 'test_helper'

class ListingTest < ActiveSupport::TestCase

def test_has_required_attributes
  assert !listings(:no_author_id).valid?
  assert !listings(:no_category).valid?
  assert !listings(:no_title).valid?
  assert !listings(:no_content).valid?
  assert !listings(:no_good_thru).valid?
  assert !listings(:no_status).valid?
  assert !listings(:no_language).valid?
  assert listings(:valid_listing).valid?
end

def test_required_attributes_not_nil
  listing_attributes_nil = Listing.new(:author_id => nil, :category => "market_place", :title => nil, 
                                       :content => nil, :good_thru => nil, :status => nil, 
                                       :language => nil)
  assert !listing_attributes_nil.valid?
end

def test_status_validation
  #testing with all valid status
    listing_status_valid = Listing.new(:author_id => "author", :category => "market_place", :title => "title", 
                                       :content => "content", :good_thru => DateTime.now+(2), 
                                       :status => "nothing_yet", :language => "fin")
                                       
    Listing::VALID_STATUS.each do |valid_status|
      listing_status_valid.status = valid_status
      assert listing_status_valid.valid?
    end

  #testing with invalid status
    listing_status_invalid = Listing.new(:author_id => "author", :category => "market_place", :title => "title", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "no_status", :language => "fin")
 
     assert !listing_status_invalid.valid?
    
end

def test_language_validation
  #test with valid language codes
  listing_language_valid = Listing.new(:author_id => "author", :category => "market_place", :title => "title", 
                                     :content => "content", :good_thru => DateTime.now+(2), 
                                     :status => "open", :language => "nothing_yet")
                                     
  Listing::VALID_LANGUAGES.each do |valid_language|
    listing_language_valid.language = valid_language
    assert listing_language_valid.valid?
  end

  #test with invalid language codes
  listing_language_invalid = Listing.new(:author_id => "author", :category => "market_place", :title => "title", 
                                       :content => "content", :good_thru => DateTime.now+(2), 
                                       :status => "open", :language => "moi")

   assert !listing_language_invalid.valid?
end


def test_length_of_title
  listing_too_long_title = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "this is a too long title for a listing as far as i know", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "open", :language => "fin")
  assert !listing_too_long_title.valid?
  
  
  listing_too_short_title = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "w", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "open", :language => "fin")
  assert !listing_too_short_title.valid?
  
  
  listing_minimum_title = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "mo", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "open", :language => "fin")
  assert listing_minimum_title.valid?
  
  
  listing_maximum_title = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "this is a valid title for a listing as far as it's", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "open", :language => "fin")
  assert listing_maximum_title.valid?
  
end

def test_length_of_value_other
  listing_too_long_value_o = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "title", :content => "content", 
                                         :good_thru => DateTime.now+(2), :status => "open", 
                                         :language => "fin", 
                                         :value_other => "asdfghjklöasdfghjklöasdfghjklöasdfghjklöasdfghjklö.")
  assert !listing_too_long_value_o.valid?
  

  listing_minimum_value_o = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "title", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "open", :language => "fin", 
                                         :value_other => "1")                                   
  assert listing_minimum_value_o.valid?
  
  listing_maximum_value_o = Listing.new(:author_id => "author", :category => "market_place", 
                                         :title => "title", 
                                         :content => "content", :good_thru => DateTime.now+(2), 
                                         :status => "open", :language => "fin",
                                         :value_other => "asdfghjklöasdfghjklöasdfghjklöasdfghjklöasdfghjklö")
  assert listing_maximum_value_o.valid?
end

def test_times_viewed
  listing_times_viewed_not_int = Listing.new(:author_id => "author", :category => "market_place", 
                                             :title => "title", :content => "content", 
                                             :good_thru => DateTime.now+(2), :status => "open", 
                                             :language => "fin", :times_viewed => 1.2)
  assert !listing_times_viewed_not_int.valid?
  
  listing_times_viewed_int = Listing.new(:author_id => "author", :category => "market_place", 
                                             :title => "title", :content => "content", 
                                             :good_thru => DateTime.now+(2), :status => "open", 
                                             :language => "fin", :times_viewed => 1)
  assert listing_times_viewed_int.valid?
  
  listing_times_viewed_nil = Listing.new(:author_id => "author", :category => "market_place", 
                                             :title => "title", :content => "content", 
                                             :good_thru => DateTime.now+(2), :status => "open", 
                                             :language => "fin", :times_viewed => nil)
  assert listing_times_viewed_nil.valid?
end

def test_value_cc
  listing_value_cc_not_int = Listing.new(:author_id => "author", :category => "market_place", 
                                             :title => "title", :content => "content", 
                                             :good_thru => DateTime.now+(2), :status => "open", 
                                             :language => "fin", :value_cc => 1.2)
  assert !listing_value_cc_not_int.valid?
  
  listing_value_cc_int = Listing.new(:author_id => "author", :category => "market_place", 
                                             :title => "title", :content => "content", 
                                             :good_thru => DateTime.now+(2), :status => "open", 
                                             :language => "fin", :value_cc => 1)
  assert listing_value_cc_int.valid?
  
  listing_value_cc_nil = Listing.new(:author_id => "author", :category => "market_place", 
                                             :title => "title", :content => "content", 
                                             :good_thru => DateTime.now+(2), :status => "open", 
                                             :language => "fin", :value_cc => nil)
  assert listing_value_cc_nil.valid?
end

def test_category_validation
  #test with valid categories
  listing_category_valid = Listing.new(:author_id => "author", :category => "nothing_yet", :title => "title", 
                                     :content => "content", :good_thru => DateTime.now+(2), 
                                     :status => "open", :language => "fin")
                                     
  Listing::VALID_CATEGORIES.each do |valid_category|
    listing_category_valid.category = valid_category
    assert listing_category_valid.valid?
  end

  #test with invalid language codes
  listing_category_invalid = Listing.new(:author_id => "author", :category => "dippa", :title => "title", 
                                       :content => "content", :good_thru => DateTime.now+(2), 
                                       :status => "open", :language => "moi")

   assert !listing_category_invalid.valid?
end

end
