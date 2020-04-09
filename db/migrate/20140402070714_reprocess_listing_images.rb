class ReprocessListingImages < ActiveRecord::Migration[5.2]
say "This migration will reprocess all the images from #{Listing.count} listings"

  def up
    ListingImage.order("id DESC").each do |listing_image|
      if listing_image.image_ready?
        Delayed::Job.enqueue(ReprocessListingImageJob.new(listing_image.id, :big), priority: 10)
      end
    end
  end
end


