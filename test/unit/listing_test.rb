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
    invalid_attributes = {
      :author_id => nil, 
      :category => nil,
      :title => nil,
      :content => nil,
      :good_thru => nil,
      :status => nil
    }
    assert_listing_valid_group(invalid_attributes, false)
  end
  
  def test_good_thru_format
    assert_listing_valid(:good_thru, DateTime.now + 7.day, true)
    assert_listing_valid(:good_thru, "huomenna", false)
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
  
  def test_status_validation
    Listing::VALID_STATUS.each do |valid_status|
      assert_listing_valid(:status, valid_status, true)
    end
    assert_listing_valid(:status, "testistatus", false)
  end  

  def test_length_of_title
    assert_listing_valid(:title, "this is a too long title for a listing as far as i know", false)
    assert_listing_valid(:title, "w", false)
    assert_listing_valid(:title, "this is a valid title for a listing as far as it's", true)
    assert_listing_valid(:title, "mo", true)
  end

  def test_length_of_value_other
    assert_listing_valid(:value_other, "asdfghjklöasdfghjklöasdfghjklöasdfghjklöasdfghjklö.", false)
    assert_listing_valid(:value_other, 1, true)
    assert_listing_valid(:value_other, "asdfghjklöasdfghjklöasdfghjklöasdfghjklöasdfghjklö", true)
  end

  def test_times_viewed_integer
    assert_listing_valid(:times_viewed, 1.2, false)
    assert_listing_valid(:times_viewed, 1, true)
    assert_listing_valid(:times_viewed, nil, true)
  end

  def test_value_cc_integer
    assert_listing_valid(:value_cc, 1.2, false)
    assert_listing_valid(:value_cc, 1, true)
    assert_listing_valid(:value_cc, nil, true)
  end

  def test_category_validation
    # Few tests to make sure that Listing.get_valid_categories
    # works correctly.
    assert_listing_valid(:category, "borrow_items", true)
    assert_listing_valid(:category, "sell", true)
    assert_listing_valid(:category, "marketplace", false)
    assert_listing_valid(:category, "dippa", false)
    # Test with all valid categories
    Listing.get_valid_categories.each do |valid_category|
      assert_listing_valid(:category, valid_category, true)
    end
  end

  def test_comments_association
    assert_equal [ listing_comments(:another_comment), listing_comments(:third_comment) ], 
    listings(:valid_listing).comments    
  end

  def test_image_validation
    listing = listings(:valid_listing)
    listing.image_file = uploaded_file("Bison_skull_pile.png", "image/png")
    assert listing.valid?
    assert listing.write_image_to_file
    listing.image_file = uploaded_file("i_am_not_image.txt", "text/plain")
    assert !listing.valid?
  end

  private
  
  def assert_listing_valid(attribute, value, is_valid)
    listing = listings(:valid_listing)
    listing.update_attribute(attribute, value)
    if is_valid
      assert listing.valid?
    else
      assert !listing.valid?
    end    
  end  
  
  def assert_listing_valid_group(values, is_valid)
    values.each do |attribute, value|
      assert_listing_valid(attribute, value, is_valid)
    end
  end

end
