class Listing::ListPresenter
  include Rails.application.routes.url_helpers

  attr_reader :community, :author, :params, :admin_mode, :per_page

  def initialize(community, author, params, admin_mode, per_page = 30)
    @author = author
    @community = community
    @params = params
    @admin_mode = admin_mode
    @per_page = per_page
  end

  def listings
    @listings ||= resource_scope.order("#{sort_column} #{sort_direction}")
                                .paginate(page: params[:page], per_page: per_page)
  end

  def reset_search_path
    if admin_mode
      admin_community_listings_path(community, locale: I18n.locale)
    else
      listings_person_settings_path(author.username, sort: "updated", locale: I18n.locale)
    end
  end

  def statuses
    return @statuses if defined?(@statuses)

    result = %w[open closed expired]
    result += [Listing::APPROVAL_PENDING, Listing::APPROVAL_REJECTED] if community.pre_approved_listings
    @statuses = result
  end

  def statuses_with_count
    statuses.map { |status| row_status(status) }
  end

  def listing_status(listing)
    if listing.approval_pending? || listing.approval_rejected?
      listing.state
    elsif listing.valid_until && listing.valid_until < DateTime.current
      'expired'
    else
      listing.open? ? 'open' : 'closed'
    end
  end

  def listing_wait_for_approval?(listing)
    listing.approval_pending?
  end

  def show_approval_link?(listing)
    admin_mode && listing_wait_for_approval?(listing)
  end

  def has_search?
    @params[:q].present? || @params[:status].present?
  end

  def show_listings_export?
    !has_search? && admin_mode
  end

  def total_listings
    count_by_status('all')
  end

  def row_status(status)
    [row_status_text(status), status]
  end

  def row_status_text(status)
    "#{I18n.t("admin.communities.listings.status.#{status}")} (#{count_by_status(status)}) "
  end

  private

  def resource_scope
    scope = community.listings.exist.includes(:author, :category)

    unless admin_mode
      scope = scope.where(author: author)
    end

    if params[:q].present?
      scope = scope.search_title_author_category(params[:q])
    end

    if params[:status].present?
      statuses = []
      statuses.push(Listing.status_open_active) if params[:status].include?('open')
      statuses.push(Listing.status_closed) if params[:status].include?('closed')
      statuses.push(Listing.status_expired) if params[:status].include?('expired')
      statuses.push(Listing.approval_pending) if params[:status].include?(Listing::APPROVAL_PENDING)
      statuses.push(Listing.approval_rejected) if params[:status].include?(Listing::APPROVAL_REJECTED)
      if statuses.size.positive?
        status_scope = statuses.slice!(0)
        statuses.map { |x| status_scope = status_scope.or(x) }
        scope = scope.merge(status_scope)
      end
    end

    scope
  end

  def count_by_status(status)
    scope = community.listings.exist
    scope = case status
            when 'open'
              scope.status_open_active
            when 'closed'
              scope.status_closed
            when 'expired'
              scope.status_expired
            when Listing::APPROVAL_PENDING
              scope.approval_pending
            when Listing::APPROVAL_REJECTED
              scope.approval_rejected
            else
              scope
            end
    scope.count
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
end
