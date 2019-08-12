class AdminTransactionsPresenter
  include Collator

  def initialize(community, params, format)
    @params = params
    @tx_search = Admin::TransactionsSearchService.new(community, params, format)
  end

  def transactions
    @tx_search.paginated
  end

  def selected_statuses_title
    if @params[:status].present?
      I18n.t("admin.communities.transactions.status_filter.selected", count: @params[:status].size)
    else
      I18n.t("admin.communities.transactions.status_filter.all")
    end
  end

  FILTER_STATUSES = %w(free confirmed paid canceled preauthorized rejected payment_intent_requires_action payment_intent_action_expired)

  def sorted_statuses
    FILTER_STATUSES.map {|status|
      [status, I18n.t("admin.communities.transactions.status_filter.#{status}"), status_checked?(status)]
    }.sort_by{|status, translation, checked| collator.get_sort_key(translation) }
  end

  def status_checked?(status)
    @params[:status].present? && @params[:status].include?(status)
  end

  def has_search?
    @params[:q].present? || @params[:status].present?
  end

  def show_link?(tx)
    exclude = %w(pending payment_intent_requires_action payment_intent_action_expired)
    !exclude.include?(tx.current_state)
  end
end
