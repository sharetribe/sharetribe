class Admin::CommunityTransactionsController < ApplicationController
  TransactionQuery = MarketplaceService::Transaction::Query
  before_filter :ensure_is_admin

  def index
    @selected_left_navi_link = "transactions"
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
      conversation = transaction[:conversation]
      # TODO Embed author and starter to the transaction entity
      # author = conversation[:other_person]
      author = Maybe(conversation[:other_person]).or_else({is_deleted: true})
      starter = Maybe(conversation[:starter_person]).or_else({is_deleted: true})

      [author, starter].each { |p|
        p[:url] = person_path(p[:username]) unless p[:username].nil?
        p[:display_name] = PersonViewUtils.person_entity_display_name(p, "fullname")
      }

      if transaction[:listing].present?
        # This if was added to tolerate cases where listing has been deleted
        # due the author deleting his/her account completely
        # UPDATE: December 2014, we did an update which keeps the listing row even if user is deleted.
        # So, we do not need to tolerate this anymore. However, there are transactions with deleted
        # listings in DB, so those have to be handled.
        transaction[:listing_url] = listing_path(id: transaction[:listing][:id])
      end

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
