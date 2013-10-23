class ReprocessListingImages < ActiveRecord::Migration
  say "This migration will reprocess all the images from #{Listing.count} listings"

  def up
    Listing.all.each do |listing|
      listing.listing_images.each do |listing_image|
        listing_image.image.reprocess! :big_cropped
        print "."
        STDOUT.flush
      end
    end
    puts ""
  end
end


