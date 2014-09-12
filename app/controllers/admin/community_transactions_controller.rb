class Admin::CommunityTransactionsController < ApplicationController
  before_filter :ensure_is_admin
  skip_filter :dashboard_only

  def index
    community = @current_community

    conversations = if params[:sort].nil? || params[:sort] == "last_activity"
      MarketplaceService::Transaction::Query::transactions_sorted_by_activity_for_community(community.id, sort_direction, pagination_opts)
    else
      MarketplaceService::Transaction::Query::transactions_sorted_by_column_for_community(community.id, simple_sort_column, sort_direction, pagination_opts)
    end

    render("index",
      { locals: {
        show_status_and_sum: community.payments_in_use?,
        community: community,
        conversations: conversations
      }}
    )
  end

  private

  def simple_sort_column(sort_column)
    case sort_column
    when "listing"
      "listings.title"
    when "started"
      "created_at"
    end
  end

  def pagination_opts
    {page: params[:page], per_page: 50}
  end

  def sort_direction
    params[:direction] || "desc"
  end
end
