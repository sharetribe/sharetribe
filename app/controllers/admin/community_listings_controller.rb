class Admin::CommunityListingsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  layout false, only: [:edit, :update]
  respond_to :html, :js

  def update
    @service.update
  end

  def approve
    @service.approve
    redirect_to listing_path(@service.listing)
  end

  def reject
    @service.reject
    redirect_to listing_path(@service.listing)
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'listings'
  end

  def set_service
    @service = Admin::ListingsService.new(
      community: @current_community,
      params: params)
    @presenter = Listing::ListPresenter.new(@current_community, @current_user, params, true)
  end
end
