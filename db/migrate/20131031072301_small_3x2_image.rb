class Small3x2Image < ActiveRecord::Migration
  say "This migration will reprocess the medium sized listing image to 3/2 aspect ratio of #{Community.count} communities"

  def up
    Listing.all.each do |listing|
      listing.listing_images.each do |listing_image|
        listing_image.image.reprocess! :small_3x2
        # This is added as the delayed_paperclip would otherwise
        # mark all images as processing, although there's no need
        # as most imagesizes are already ok.
        # Setting image_processing to false doesn't stop small_3x2 from 
        # being created in the background job
        listing_image.update_column(:image_processing, false)
        print "."
        STDOUT.flush
      end
    end
    puts ""
  end
end
