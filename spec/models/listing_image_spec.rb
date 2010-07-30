require 'spec_helper'

describe ListingImage do
  
  it "is valid when a valid image file is added" do
    @listing_image = ListingImage.new(:image => uploaded_file("Bison_skull_pile.png", "image/png"))
    @listing_image.should be_valid
  end
  
  it "is not valid when an invalid file is added" do
    @listing_image = ListingImage.new(:image => uploaded_file("i_am_not_image.txt", "text/plain"))
    @listing_image.should_not be_valid
  end
  
end
