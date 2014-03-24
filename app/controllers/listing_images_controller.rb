class ListingImagesController < ApplicationController
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:destroy]

  before_filter :fetch_image, :only => [:destroy]
  before_filter :"listing_image_authorized?", :only => [:destroy]

  before_filter :fetch_listing, :only => [:add_from_file]
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

  # New listing image while creating a new listing
  # Create image from uploaded file
  def create_from_file
    binding.pry
    create_image(params[:listing_image], nil)
  end

  # New listing image while creating a new listing
  # Create image from given url
  def create_from_url
    binding.pry
    url = params[:image_url]

    if !url.present?
      render json: {:errors => "No image URL provided"}, status: 400
    end

    create_image({}, url)
  end

  # Add new listing image to existing listing
  # Create image from given url
  def add_from_url
    binding.pry
    url = params[:image_url]

    if !url.present?
      render json: {:errors => "No image URL provided"}, status: 400
    end

    add_image({}, url)
  end

  # Add new listing image to existing listing
  # Create image from uploaded file
  def add_from_file
    binding.pry
    add_image(params[:listing_image], nil)
  end

  # Return image status and thumbnail url
  def image_status
    listing_image = ListingImage.find_by_id_and_author_id(params[:id], @current_user.id)

    if !listing_image
      render nothing: true, status: 404
    elsif !listing_image.image_downloaded || listing_image.image_processing
      render json: {processing: true}, status: 200
    else
      render json: {processing: false, thumb: listing_image.image.url(:thumb)}, status: 200
    end
  end

  private

  # Create new listing
  def create_image(params, url)
    listing_image_params = params.merge(
      author: @current_user
    )

    new_image(listing_image_params, url)
  end

  def add_image(params, url)
    listing_id = params[:listing_id]

    if listing_id
      ListingImage.destroy_all(listing_id: listing_id)
    end

    listing_image_params = params.merge(
      author: @current_user,
      listing_id: listing_id
    )

    new_image(listing_image_params, url)
  end

  # Create a new image object
  def new_image(params, url)
    listing_image = ListingImage.new(params)

    if listing_image.save
      after_save_safg(listing_image, url)
      binding.pry
      render json: {
        id: listing_image.id, 
        removeUrl: listing_image_path(listing_image),
        processedPollingUrl: image_status_listing_image_path(listing_image)
      }, status: 202
    else
      render json: {:errors => listing_image.errors.full_messages}, status: 400
    end
  end

  # After image saved to database
  def after_save_safg(listing_image, url)
    if url
      listing_image.download_from_url(url)
      listing_image.update_attribute(:image_downloaded, false)
    else
      listing_image.update_attribute(:image_downloaded, true)
    end
  end

  def fetch_image
    @listing_image = ListingImage.find_by_id(params[:id])
  end

  def fetch_listing
    @listing = Listing.find_by_id(params[:listing_id])
  end

  def listing_image_authorized?
    @listing_image.authorized?(@current_user)
  end
end
