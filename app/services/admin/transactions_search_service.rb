module Admin
  class TransactionsSearchService
    def initialize(community, params, format)
      @community = community
      @params = params
      @format = format
      @pagination_opts = PaginationViewUtils.parse_pagination_opts(params)
    end

    def results
      if @params[:sort].nil? || @params[:sort] == "last_activity"
        transactions_search_scope.for_community_sorted_by_activity(
          @community.id,
          sort_direction,
          @pagination_opts[:limit],
          @pagination_opts[:offset],
          @format == :csv)
      else
        transactions_search_scope.for_community_sorted_by_column(
          @community.id,
          simple_sort_column(@params[:sort]),
          sort_direction,
          @pagination_opts[:limit],
          @pagination_opts[:offset])
      end
    end

    def count
      transactions_search_scope.exist.by_community(@community.id).with_payment_conversation.count
    end

    def paginated
      WillPaginate::Collection.create(@pagination_opts[:page], @pagination_opts[:per_page], count) do |pager|
        pager.replace(results)
      end
    end

    def transactions_search_scope
      scope = Transaction
      if @params[:q].present?
        pattern = "%#{@params[:q]}%"
        scope = scope.search_by_party_or_listing_title(pattern)
      end
      if @params[:status].present?
        scope = scope.where(current_state: @params[:status])
      end
      scope
    end

    def simple_sort_column(sort_column)
      case sort_column
      when "listing"
        "listings.title"
      when "started"
        "created_at"
      end
    end

    def sort_direction
      if @params[:direction] == "asc"
        "asc"
      else
        "desc" #default
      end
    end
  end
end
