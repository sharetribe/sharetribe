require 'spec_helper'

describe ListingImage do

  it "is valid without image" do
    @listing_image = ListingImage.new()
    @listing_image.should be_valid
  end
  
  it "is valid when a valid image file is added" do
    @listing_image = ListingImage.new(:image => uploaded_file("Bison_skull_pile.png", "image/png"))
    @listing_image.should be_valid
  end
  
  it "is not valid when an invalid file is added" do
    @listing_image = ListingImage.new(:image => uploaded_file("i_am_not_image.txt", "text/plain"))
    @listing_image.should_not be_valid
  end

  it "detects right sized image for given aspect ratio" do
    aspect_ratio = 3/2.to_f
    expect(ListingImage.correct_size?(200, 400, aspect_ratio)).to eql(false)
    
    # Edges
    expect(ListingImage.correct_size?(599, 400, aspect_ratio)).to eql(false)
    expect(ListingImage.correct_size?(600, 400, aspect_ratio)).to eql(true)
    expect(ListingImage.correct_size?(601, 400, aspect_ratio)).to eql(false)
    
    expect(ListingImage.correct_size?(800, 400, aspect_ratio)).to eql(false)
  end 

  it "detects too narrow dimensions for given aspect ratio" do
    aspect_ratio = 3/2.to_f
    expect(ListingImage.too_narrow?(200, 400, aspect_ratio)).to eql(true)
    
    # Edges
    expect(ListingImage.too_narrow?(599, 400, aspect_ratio)).to eql(true)
    expect(ListingImage.too_narrow?(600, 400, aspect_ratio)).to eql(false)
    expect(ListingImage.too_narrow?(601, 400, aspect_ratio)).to eql(false)
    
    expect(ListingImage.too_narrow?(800, 400, aspect_ratio)).to eql(false)
  end

  it "detects too wide dimensions for given aspect ratio" do
    aspect_ratio = 3/2.to_f
    expect(ListingImage.too_wide?(200, 400, aspect_ratio)).to eql(false)
    
    # Edges
    expect(ListingImage.too_wide?(599, 400, aspect_ratio)).to eql(false)
    expect(ListingImage.too_wide?(600, 400, aspect_ratio)).to eql(false)
    expect(ListingImage.too_wide?(601, 400, aspect_ratio)).to eql(true)
    
    expect(ListingImage.too_wide?(800, 400, aspect_ratio)).to eql(true)
  end
  
end
