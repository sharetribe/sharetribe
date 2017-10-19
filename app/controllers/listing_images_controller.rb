class ListingImagesController < ApplicationController

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_action :verify_authenticity_token, :only => [:destroy]
  skip_before_action :warn_about_missing_payment_info

  before_action :"ensure_authorized_to_add!", :only => [:add_from_file, :add_from_url, :reorder]

  def destroy
    image = ListingImage.find_by_id(params[:id])

    if image.nil?
      render body: nil, status: 404
    elsif !authorized_to_destroy?(image)
      render body: nil, status: 401
    else
      image_destroyed = image.destroy

      if image_destroyed
        render body: nil, status: 204
      else
        error_messages = image.errors.full_messages

        render json: {errors: listing_image.errors.full_messages}, status: 500

        logger.error("Failed to destroy listing image",
                     :image_destroy_failed,
                     listing_image_id: image.id,
                     params: params,
                     errors: error_messages)
      end
    end
  end

  # Add new listing image to existing listing
  # Create image from given url
  def add_from_url
    url = escape_s3_url(params[:path], params[:filename])

    if !url.present?
      logger.info("No image URL provided", :no_image_url_provided, params)
      render json: {:errors => "No image URL provided"}, status: 400, content_type: 'text/plain'
    end

    add_image(params[:listing_id], {}, url)
  end

  # Add new listing image to existing listing
  # Create image from uploaded file
  def add_from_file
    listing_image_params = params.require(:listing_image).permit(:image)
    add_image(params[:listing_id], listing_image_params, nil)
  end

  # Return image status and thumbnail url
  def image_status
    listing_image = ListingImage.find_by_id(params[:id])

    if !listing_image
      render body: nil, status: 404
    else
      render json: ListingImageJSAdapter.new(listing_image).to_json, status: 200
    end
  end

  def reorder
    params[:ordered_ids].split(",").each_with_index do |image_id, index|
      ListingImage.where(listing_id: params[:listing_id], id: image_id).update_all(position: index+1) # rubocop:disable Rails/SkipsModelValidations
    end
    render plain: "OK"
  end

  private

  # Given path which includes placeholder `${filename}` and
  # the `filename` and get back working URL
  def escape_s3_url(path, filename)
    escaped_filename = CGI.escape(filename.encode('UTF-8')).gsub('+', '%20').gsub('%7E', '~')
    path.sub("${filename}", escaped_filename)
  end

  def add_image(listing_id, params, url)
    listing_image_params = params.merge(
      author_id: @current_user.id,
      listing_id: listing_id
    )

    new_image(listing_image_params, url)
  end

  # Create a new image object
  def new_image(params, url)
    listing_image = ListingImage.new(params)

    listing_image.image_downloaded = if url.present? then false else true end

    if listing_image.save
      if !listing_image.image_downloaded
        logger.info("Asynchronously downloading image", :start_async_image_download, listing_image_id: listing_image.id, url: url, params: params)
        Delayed::Job.enqueue(DownloadListingImageJob.new(listing_image.id, url), priority: 1)
      else
        logger.info("Listing image is already downloaded", :image_already_downloaded, listing_image_id: listing_image.id, params: params.except(:image))
      end

      render json: ListingImageJSAdapter.new(listing_image).to_json, status: 202, content_type: 'text/plain' # Browsers without XHR fileupload support do not support other dataTypes than text
    else
      logger.error("Saving listing image failed", :saving_listing_image_failed, params: params, errors: listing_image.errors.messages)
      render json: {:errors => listing_image.errors.full_messages}, status: 400, content_type: 'text/plain'
    end
  end

  def authorized_to_destroy?(image)
    if image.listing.present? && image.listing.community_id == @current_community.id
      # Listing is present: We are deleting image from saved listing
      image.listing.author == @current_user || @current_user.has_admin_rights?(@current_community)
    else
      # Listing is not present: We are deleting image from a new unsaved listing
      image.author == @current_user
    end
  end

  def ensure_authorized_to_add!
    listing_id = params[:listing_id]

    status =
      if listing_id.nil?
        :authorized
      else
        listing = @current_community.listings.find_by(id: listing_id)

        if listing.nil?
          :not_found
        elsif listing.author == @current_user || @current_user.has_admin_rights?(@current_community)
          :authorized
        else
          :unauthorized
        end
      end

    case status
    when :not_found
      render body: nil, status: :not_found
    when :unauthorized
      render body: nil, status: :unauthorized
    end
  end
end
