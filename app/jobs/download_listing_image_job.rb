class DownloadListingImageJob < Struct.new(:listing_image_id, :url)

  include DelayedAirbrakeNotification

  def perform
    # Whou, paperclip and delayed paperclip gems are giving us a handful of black magic here.
    #
    # Setting `self.image` will download the image to local filesystem, if URL is given.
    # It may throw.
    #
    # Calling `update_attribute` will save the original size image to S3 and create a new background
    # job to resize the image. It will also save the new image value to database.
    # It's doing network operations, so I guess it can also throw.
    #

    find_listing_image(listing_image_id).and_then { |listing_image|

      # Download the original image
      begin
        listing_image.image = URI.parse(url)
        Result::Success.new(listing_image)
      rescue StandardError => e
        Result::Error.new(e)
      end

    }.and_then { |listing_image|

      # Save the image, create delayed jobs for processing, update the download status
      begin
        listing_image.update_attribute(:image_downloaded, true)
        Result::Success.new(listing_image)
      rescue StandardError => e
        Result::Error.new(e)
      end

    }.on_error { |error_msg, data|
      logger.error(error_msg, :listing_image_download_failed, data)
    }
  end

  private

  def logger
    @logger ||= SharetribeLogger.new(:download_listing_image_job)
  end

  def find_listing_image(listing_image_id)
    Maybe(ListingImage.where(id: listing_image_id).first).map { |listing_image|
      Result::Success.new(listing_image)
    }.or_else {
      Result::Error.new("Could not find listing image with id #{listing_image_id}",
                        :listing_image_not_found,
                        listing_image_id: listing_image_id)
    }
  end
end
