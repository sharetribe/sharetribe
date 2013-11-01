class Small3x2Image < ActiveRecord::Migration
  say "This migration will reprocess the medium sized listing image to 3/2 aspect ratio of #{Community.count} communities"

  def up
    Listing.all.each do |listing|
      listing.listing_images.each do |listing_image|
        listing_image.image.reprocess! :small_3x2
        print "."
        STDOUT.flush
      end
    end
    puts ""
  end
end
