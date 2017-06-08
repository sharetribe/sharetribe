# == Schema Information
#
# Table name: listing_images
#
#  id                 :integer          not null, primary key
#  listing_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_processing   :boolean
#  image_downloaded   :boolean          default(FALSE)
#  error              :string(255)
#  width              :integer
#  height             :integer
#  author_id          :string(255)
#  position           :integer          default(0)
#
# Indexes
#
#  index_listing_images_on_listing_id  (listing_id)
#

require 'spec_helper'

describe ListingImage, type: :model do

  it "is valid without image" do
    @listing_image = ListingImage.new()
    expect(@listing_image).to be_valid
  end

  it "is valid when a valid image file is added" do
    @listing_image = ListingImage.new(:image => uploaded_file("Bison_skull_pile.png", "image/png"))
    expect(@listing_image).to be_valid
  end

  it "is not valid when an invalid file is added" do
    @listing_image = ListingImage.new(:image => uploaded_file("i_am_not_image.txt", "text/plain"))
    expect(@listing_image).not_to be_valid
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

  it "scales image to cover given area, preserves aspect ratio" do
    def test(width, height, expected_width, expected_height)
      expect(ListingImage.scale_to_cover({:width => width, :height => height}, {:width => 600, :height => 400})).to eql({:width => expected_width, :height => expected_height })
    end

    test(300, 100, 1200.0, 400.0)
    test(300, 200, 600.0, 400.0)
    test(300, 400, 600.0, 800.0)
    test(300, 800, 600.0, 1600.0)

    test(150, 400, 600.0, 1600.0)
    test(300, 400, 600.0, 800.0)
    test(600, 400, 600.0, 400.0)
    test(1200, 400, 1200.0, 400.0)

    test(2448, 3264, 600.0, 800.0)
  end

  it "returns image styles, crops landscape big images if needed" do
    def test(width, height, expected)
      expect(ListingImage.construct_big_style({:width => width, :height => height}, {:width => 600, :height => 400}, 0.2)).to eq expected
    end

    test(479, 400, "600x400>")  # Width crop 0%, height crop 20% and a little bit more
    test(480, 400, "600x400#")  # Width crop 0%, height crop 20%
    test(600, 400, "600x400#")  # Width crop 0%, height crop 0%
    test(750, 400, "600x400#")  # Width crop 20%, height crop 0%
    test(751, 400, "600x400>")  # Width crop 20% and a little bit more, height crop 0%

    test(600, 319, "600x400>")  # Width crop 20% and a little bit more, height crop 0%
    test(600, 320, "600x400#")  # Width crop 20%, height crop 0%
    test(600, 400, "600x400#")  # Width crop 0%, height crop 0%
    test(600, 500, "600x400#")  # Width crop 0%, height crop 20%
    test(600, 501, "600x400>")  # Width crop 0%, height crop 20% and a little bit more
  end
end
