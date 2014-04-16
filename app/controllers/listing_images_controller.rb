class ListingImagesController < ApplicationController

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:destroy]

  before_filter :fetch_image, :only => [:destroy]
  before_filter :"listing_image_authorized?", :only => [:destroy]

  before_filter :"listing_authorized?", :only => [:add_from_file]

  skip_filter :dashboard_only

  def destroy
    @listing_image_id = @listing_image.id.to_s
    if @listing_image.destroy
      render nothing: true, status: 204
    else
      render json: {:errors => listing_image.errors.full_messages}, status: 400
    end
  end

  # Add new listing image to existing listing
  # Create image from given url
  def add_from_url
    url = escape_s3_url(params[:path], params[:filename])

    if !url.present?
      render json: {:errors => "No image URL provided"}, status: 400, content_type: 'text/plain'
    end

    add_image(params[:listing_id], {}, url)
  end

  # Add new listing image to existing listing
  # Create image from uploaded file
  def add_from_file
    add_image(params[:listing_id], params[:listing_image], nil)
  end

  # Return image status and thumbnail url
  def image_status
    listing_image = ListingImage.find_by_id(params[:id])

    if !listing_image
      render nothing: true, status: 404
    else
      render json: ListingImageJSAdapter.new(listing_image).to_json, status: 200
    end
  end

  private

  # Given path which includes placeholder `${filename}` and
  # the `filename` and get back working URL
  def escape_s3_url(path, filename)
    escaped_filename = AWS::Core::UriEscape.escape(filename)
    path.sub("${filename}", escaped_filename)
  end

  def add_image(listing_id, params, url)
    # if listing_id
    #   ListingImage.destroy_all(listing_id: listing_id)
    # end

    listing_image_params = params.merge(
      author: @current_user,
      listing_id: listing_id
    )

    new_image(listing_image_params, url)
  end

  # Create a new image object
  def new_image(params, url)
    listing_image = ListingImage.new(params)

    listing_image.image_downloaded = if url.present? then false else true end

    if listing_image.save
      unless listing_image.image_downloaded
        listing_image.delay.download_from_url(url)
      end
      render json: ListingImageJSAdapter.new(listing_image).to_json, status: 202, content_type: 'text/plain' # Browsers without XHR fileupload support do not support other dataTypes than text
    else
      render json: {:errors => listing_image.errors.full_messages}, status: 400, content_type: 'text/plain'
    end
  end

  def fetch_image
    @listing_image = ListingImage.find_by_id(params[:id])
  end

  def listing_image_authorized?
    @listing_image.authorized?(@current_user)
  end

  def listing_authorized?
    listing = Listing.find_by_id(params[:listing_id])
    if listing.nil?
      true
    else
      listing.author == @current_user
    end
  end
end
