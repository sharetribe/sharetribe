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

    @result = listing_image.and_then { |listing_image|

      begin
        # Download the original image
        listing_image.image = URI.parse(url)
        # Save the image, create delayed jobs for processing, update the download status
        listing_image.update_attribute(:image_downloaded, true)
        Result::Success.new(listing_image)
      rescue StandardError => e
        Result::Error.new(e)
      end

    }

    @result.on_error { |error_msg, ex|
      logger.error(error_msg, :listing_image_download_failed)

      raise ex # Reraise the exception to mark the delayed job failed
    }
  end

  def failure
    @result.on_error { |error_msg|
      logger.error("Listing image process and download failed permanently: #{error_msg}", :listing_image_download_failed_permanently)

      listing_image.on_success { |image|
        # Have to use `update_column` here because `update_attribute` runs the before save hooks
        image.update_column(:error, error_msg || "unknown")
      }
    }
  end

  private

  def logger
    @logger ||= SharetribeLogger.new(:download_listing_image_job, logger_metadata.keys).tap { |logger|
      logger.add_metadata(logger_metadata)
    }
  end

  def logger_metadata
    @logger_metadata ||=
      if listing_image.success
        listing_image.data.attributes
      else
        {}
      end
  end

  def listing_image
    @listing_image ||= Maybe(ListingImage.where(id: listing_image_id).first).map { |listing_image|
      Result::Success.new(listing_image)
    }.or_else {
      Result::Error.new(ArgumentError.new("Could not find listing image with id #{listing_image_id}"))
    }
  end
end
