class ListingImageJSAdapter < JSAdapter

  ASPECT_RATIO = 3/2.to_f

  def initialize(listing_image)
    @id = listing_image.id
    @listing_id = listing_image.listing_id
    @processing = listing_image.image_processing
    @downloaded = listing_image.image_downloaded
    @images = {
      thumb: listing_image.image.url(:thumb),
      big: listing_image.image.url(:big)
    }
    @urls = {
      remove: listing_image_path(listing_image.id),
      status: image_status_listing_image_path(listing_image)
    }
    @aspect_ratio = if listing_image.correct_size? ASPECT_RATIO
        "correct-ratio"
      elsif listing_image.too_narrow? ASPECT_RATIO
        "too-narrow"
      else
        "too-wide"
      end
  end
end