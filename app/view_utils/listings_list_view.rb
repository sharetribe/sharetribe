class ListingsListView
  def initialize(community, author, params)
    @author = author
    @community = community
    @params = params
  end

  def resource_scope
    scope = @community.listings.exist.includes(:author, :category)

    if @author
      scope = scope.where(author: @author)
    end

    if @params[:q].present?
      scope = scope.search_title_author_category(@params[:q])
    end

    if @params[:status].present?
      statuses = []
      statuses.push(Listing.status_open) if @params[:status].include?('open')
      statuses.push(Listing.status_closed) if @params[:status].include?('closed')
      statuses.push(Listing.status_expired) if @params[:status].include?('expired')
      if statuses.size > 1
        status_scope = statuses.slice!(0)
        statuses.map{|x| status_scope = status_scope.or(x)}
        scope = scope.merge(status_scope)
      else
        scope = scope.merge(statuses.first)
      end
    end

    scope.order("#{sort_column} #{sort_direction}")
  end

  def sort_column
    case @params[:sort]
    when 'started'
      'listings.created_at'
    when 'updated', nil
      'listings.updated_at'
    end
  end

  def sort_direction
    @params[:direction] == 'asc' ? 'asc' : 'desc'
  end
end
