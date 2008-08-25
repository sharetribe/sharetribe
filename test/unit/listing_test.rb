require 'test_helper'

class ListingTest < ActiveSupport::TestCase
  
  def test_language_is_serialized
    listing = Listing.new(:author_id => "emmi", :category => "sell", :title => "otsikko", 
                           :content => "asdfghjklöäasdfghjköä asdfghjklöäasdfghjklöä asdfghjklöä",
                           :good_thru => DateTime.now+7.day, 
                           :times_viewed => 34, :status => "open", :value_cc => 13, 
                           :language => ["fi", "swe"],
                           :value_other => "viiniä")

    listing.save
    
    assert listing.valid?
    
    retrieved = Listing.find(:last)
    assert_equal "fi", retrieved.language[0]
    assert_equal "swe", retrieved.language[1]
    assert_equal nil, retrieved.language[2]
  end
  
  def test_language_not_empty
    listing = Listing.new(:author_id => "emmi", :category => "sell", :title => "otsikko", 
                          :content => "asdfghjklöäasdfghjköä asdfghjklöäasdfghjklöä asdfghjklöä",
                          :good_thru => DateTime.now+7.day, 
                          :times_viewed => 34, :status => "open", :value_cc => 13, 
                          :language => [],
                          :value_other => "viiniä")
                                                
    assert !listing.valid?
  end
  
  def test_language_one_of_valid_ones
    listing = Listing.new(:author_id => "emmi", :category => "sell", :title => "otsikko", 
                          :content => "asdfghjklöäasdfghjköä asdfghjklöäasdfghjklöä asdfghjklöä",
                          :good_thru => DateTime.now+7.day, 
                          :times_viewed => 34, :status => "open", :value_cc => 13, 
                          :language => ["testi"],
                          :value_other => "viiniä")
    assert !listing.valid?
    
    Listing::VALID_LANGUAGES.each_with_index do |valid_language, index|
       listing.language[index] = valid_language
       assert listing.valid?
     end
     
  end

  def test_has_required_attributes
     assert listings(:valid_listing).valid?
     
     #not valid without author_id
     listing = listings(:valid_listing)
     listing.author_id = nil
     assert !listing.valid?
     
     #not valid without category
     listing = listings(:valid_listing)
     listing.category = nil
     assert !listing.valid?
     
     #not valid without title
     listing = listings(:valid_listing)
     listing.title = nil
     assert !listing.valid?
     
     #not valid without content
     listing = listings(:valid_listing)
     listing.content = nil
     assert !listing.valid?
     
     #not valid without good_thru
     listing = listings(:valid_listing)
     listing.good_thru = nil
     assert !listing.valid?
     
     #not valid without status
     listing = listings(:valid_listing)
     listing.status = nil
     assert !listing.valid?
     
   end
  
   def test_date_not_valid_format
     listing = listings(:valid_listing)
     listing.good_thru = "huomenna"
     assert !listing.valid?
   end
  
   def test_good_thru_too_big
     listing = Listing.new(:author_id => "maija", :category => "sell", :title => "otsikko", 
                           :content => "asdfghjklöäasdfghjköä asdfghjklöäasdfghjklöä asdfghjklöä",
                           :good_thru => DateTime.now+2.year, 
                           :times_viewed => 34, :status => "open",
                           :language => ["swe"], :value_cc => 13, :value_other => "viiniä")
     assert !listing.valid?
   end
     
   def test_good_thru_too_small
     listing = Listing.new(:author_id => "maija", :category => "sell", :title => "otsikko", 
                           :content => "asdfghjklöäasdfghjköä asdfghjklöäasdfghjklöä asdfghjklöä",
                           :good_thru => DateTime.now - 1.day, :times_viewed => 34, :status => "open",
                           :language => ["fi", "swe"], :value_cc => 13, :value_other => "viiniä")
     assert !listing.valid?
   end
  
   def test_good_thru_ok
     listing = listings(:valid_listing)  
     #date ok
     listing.good_thru = DateTime.now + 7.day
     assert listing.valid?
     
   end
  
   def test_status_validation
     #testing with all valid status
     listing_status_valid = listings(:valid_listing) 
  
     Listing::VALID_STATUS.each do |valid_status|
       listing_status_valid.status = valid_status
       assert listing_status_valid.valid?
     end
  
     #testing with invalid status
     listing_status_invalid = listings(:valid_listing)
     listing_status_invalid.status = "testi_status"
     assert !listing_status_invalid.valid?
  
   end
  
   #def test_language_validation
   #  #test with valid language codes
   #  listing_language_valid = listings(:valid_listing)
   #
   #  Listing::VALID_LANGUAGES.each do |valid_language|
   #    listing_language_valid.language = valid_language
   #    assert listing_language_valid.valid?
   #  end
  
     #test with invalid language codes
   #  listing_language_invalid = listings(:valid_listing)
   #  listing_language_invalid.language = "moi"
   #  assert !listing_language_invalid.valid?
   #end
  
  
   def test_length_of_title
     listing_too_long_title = listings(:valid_listing)
     listing_too_long_title.title = "this is a too long title for a listing as far as i know"
     assert !listing_too_long_title.valid?
  
  
     listing_too_short_title = listings(:valid_listing)
     listing_too_short_title.title = "w"
     assert !listing_too_short_title.valid?
  
     listing_minimum_title = listings(:valid_listing)
     listing_minimum_title.title = "mo"
     assert listing_minimum_title.valid?
  
     listing_maximum_title = listings(:valid_listing)
     listing_maximum_title.title = "this is a valid title for a listing as far as it's"
     assert listing_maximum_title.valid?
  
   end
  
   def test_length_of_value_other
     listing_too_long_value_o = listings(:valid_listing)
     listing_too_long_value_o.value_other = "asdfghjklöasdfghjklöasdfghjklöasdfghjklöasdfghjklö."
     assert !listing_too_long_value_o.valid?
  
  
     listing_minimum_value_o = listings(:valid_listing)
     listing_minimum_value_o.value_other = "1"                               
     assert listing_minimum_value_o.valid?
  
     listing_maximum_value_o = listings(:valid_listing)
     listing_maximum_value_o.value_other = "asdfghjklöasdfghjklöasdfghjklöasdfghjklöasdfghjklö"
     assert listing_maximum_value_o.valid?
   end
  
   def test_times_viewed
     listing_times_viewed_not_int = listings(:valid_listing)
     listing_times_viewed_not_int.times_viewed = 1.2
     assert !listing_times_viewed_not_int.valid?
  
     listing_times_viewed_nil = listings(:valid_listing)
     listing_times_viewed_nil.times_viewed = nil
     assert listing_times_viewed_nil.valid?
   end
  
   def test_value_cc
     listing_value_cc_not_int = listings(:valid_listing)
     listing_value_cc_not_int.value_cc = 1.2
     assert !listing_value_cc_not_int.valid?
  
     listing_value_cc_nil = listings(:valid_listing)
     listing_value_cc_nil.value_cc = nil
     assert listing_value_cc_nil.valid?
   end
  
   def test_category_validation
     #test with valid categories
     listing_category_valid = listings(:valid_listing)
  
     Listing::VALID_CATEGORIES.each do |valid_category|
       listing_category_valid.category = valid_category
       assert listing_category_valid.valid?
     end
  
     #test with invalid language codes
     listing_category_invalid = listings(:valid_listing)
     listing_category_invalid.category = "dippa"
     assert !listing_category_invalid.valid?
   end
 
   def test_comments_association
     assert_equal [ listing_comments(:another_comment), listing_comments(:third_comment) ], 
     listings(:valid_listing).comments    
   end   
 
end
