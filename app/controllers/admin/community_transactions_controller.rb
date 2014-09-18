class Admin::CommunityTransactionsController < ApplicationController
  TransactionQuery = MarketplaceService::Transaction::Query
  before_filter :ensure_is_admin
  skip_filter :dashboard_only

  def index
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    conversations = if params[:sort].nil? || params[:sort] == "last_activity"
      TransactionQuery.transactions_for_community_sorted_by_activity(
        @current_community.id,
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset])
    else
      TransactionQuery.transactions_for_community_sorted_by_column(
        @current_community.id,
        simple_sort_column(params[:sort]),
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset])
    end

    count = TransactionQuery.transactions_count_for_community(@current_community.id)

    # TODO THIS IS COPY-PASTE
    conversations = conversations.map do |transaction|
      author_id = transaction[:listing][:author_id]
      starter_id = transaction[:starter_id]

      author = transaction[:conversation][:participants].find { |participant| participant[:id] == author_id }
      starter = transaction[:conversation][:participants].find { |participant| participant[:id] == starter_id }

      author_url = {url: person_path(id: author[:username])}
      starter_url = {url: person_path(id: starter[:username])}

      transaction[:listing_url] = listing_path(id: transaction[:listing][:id])

      transaction.merge({author: author, starter: starter})
    end

    conversations = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
      pager.replace(conversations)
    end

    render("index",
      { locals: {
        show_status_and_sum: @current_community.payments_in_use?,
        community: @current_community,
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

  def sort_direction
    params[:direction] || "desc"
  end
end
