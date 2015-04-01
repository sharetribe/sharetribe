class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  # TODO before_filter :feature_flag

  def index
    render("index",
           locals: {
             selected_left_navi_link: "listing_shapes",
             listing_shapes: listing_api.shapes.get(community_id: @current_community.id).maybe().or_else([])})
  end


  private

  def listing_api
    ListingService::API::Api
  end
end
