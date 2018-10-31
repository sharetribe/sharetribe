class Admin::CommunityListingsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "listings"
    @listings = resource_scope.order("#{sort_column} #{sort_direction}")
      .paginate(:page => params[:page], :per_page => 30)
  end

  private

  def resource_scope
    scope = @current_community.listings.exist.includes(:author, :category)
    if params[:q].present?
      scope = scope.search_title_author_category(params[:q])
    end
    if params[:status].present?
      # when both "open" and "closed" are selected - do not change scope
      unless params[:status].include?("open") && params[:status].include?("closed")
        scope = scope.status_open    if params[:status].include?("open")
        scope = scope.status_closed  if params[:status].include?("closed")
      end
      if params[:status].include?("expired")
        scope = scope.status_expired
      end
    end
    scope
  end

  def sort_column
    case params[:sort]
    when 'started'
      'listings.created_at'
    when 'updated', nil
      'listings.updated_at'
    end
  end

  def sort_direction
    params[:direction] == 'asc' ? 'asc' : 'desc'
  end

  helper_method :listing_search_status_titles

  def listing_search_status_titles
    if params[:status].present?
      params[:status].map{|s| I18n.t("admin.communities.listings.status.#{s}") }.join(", ")
    else
      I18n.t("admin.communities.listings.status.all")
    end
  end
end
