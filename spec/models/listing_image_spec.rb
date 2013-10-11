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

  it "returns true for portrait image" do
    expect(ListingImage.portrait?({:width => 1000, :height => 200})).to eq(false)
    expect(ListingImage.portrait?({:width => 200, :height => 1000})).to eq(true)
    expect(ListingImage.portrait?({:width => 1000, :height => 1000})).to eq(false)
  end

  it "scales height down and preserves aspect ratio" do
    # Up
    expect(ListingImage.scale_height_down({:width => 300, :height => 200}, 400)).to eq({:width => 300, :height => 200})

    # Down
    expect(ListingImage.scale_height_down({:width => 1200, :height => 800}, 400)).to eq({:width => 600, :height => 400})
  end

  it "returns image with slides cropped" do
    # Landscape
    expect(ListingImage.crop_landscape_sides({:width => 600, :height => 400}, 600, 0.2)).to eq({:width => 600, :height => 400})
    expect(ListingImage.crop_landscape_sides({:width => 601, :height => 400}, 600, 0.2)).to eq({:width => 600, :height => 400})
    expect(ListingImage.crop_landscape_sides({:width => 750, :height => 400}, 600, 0.2)).to eq({:width => 600, :height => 400})
    expect(ListingImage.crop_landscape_sides({:width => 751, :height => 400}, 600, 0.2)).to eq({:width => 601, :height => 400})
    expect(ListingImage.crop_landscape_sides({:width => 800, :height => 400}, 600, 0.2)).to eq({:width => 640, :height => 400})

    # Narrow landscape image
    expect(ListingImage.crop_landscape_sides({:width => 1200, :height => 300}, 600, 0.2)).to eq({:width => 960, :height => 300})

  end

  it "returns image styles, crops landscape big images if needed" do
    # Portrait
    expect(ListingImage.construct_big_style({:width => 600, :height => 1200}, 0.2)).to eq "660x440>"

    # Landscape, crop need 0.1, max 0.2
    expect(ListingImage.construct_big_style({:width => 666, :height => 400}, 0.2)).to eq "660x400#"

    # Landscape, crop need 0.2, max 0.2
    expect(ListingImage.construct_big_style({:width => 750, :height => 440}, 0.2)).to eq "660x440#"

    # Landscape, crop need 0.5, max 0.2
    expect(ListingImage.construct_big_style({:width => 1200, :height => 400}, 0.2)).to eq "960x400#"
  end
end
