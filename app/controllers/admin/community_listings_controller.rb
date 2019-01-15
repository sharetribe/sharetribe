class Admin::CommunityListingsController < Admin::AdminBaseController
  def index
    @selected_left_navi_link = "listings"
    @presenter = Listing::ListPresenter.new(@current_community, @current_user, params, true)
  end
end
