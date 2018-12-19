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
      statuses = []
      statuses.push(Listing.status_open) if params[:status].include?('open')
      statuses.push(Listing.status_closed) if params[:status].include?('closed')
      statuses.push(Listing.status_expired) if params[:status].include?('expired')
      if statuses.size > 1
        status_scope = statuses.slice!(0)
        statuses.map{|x| status_scope = status_scope.or(x)}
        scope = scope.merge(status_scope)
      else
        scope = scope.merge(statuses.first)
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
      I18n.t("admin.communities.listings.status.selected_js") + params[:status].size.to_s
    else
      I18n.t("admin.communities.listings.status.all")
    end
  end
end
