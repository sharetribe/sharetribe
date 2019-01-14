class Admin::CommunityListingsController < Admin::AdminBaseController
  def index
    @selected_left_navi_link = "listings"
    @admin_mode = true

    @listings = ListingsListView.new(@current_community, nil, params)
      .resource_scope
      .paginate(:page => params[:page], :per_page => 30)
  end
end
