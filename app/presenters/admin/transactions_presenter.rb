class Admin::TransactionsPresenter
  include Collator

  private

  attr_reader :service

  public

  def initialize(params, service)
    @params = params
    @service = service
  end

  delegate :transactions, :transaction, :community, to: :service, prefix: false

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

  def show_admin_link?
    FeatureFlagHelper.feature_enabled?(:new_tx_page)
  end

  def listing_title
    transaction.listing_title
  end

  def localized_unit_type
    transaction.unit_type.present? ? ListingViewUtils.translate_unit(transaction.unit_type, transaction.unit_tr_key) : nil
  end

  def localized_selector_label
    transaction.unit_type.present? ? ListingViewUtils.translate_quantity(transaction.unit_type, transaction.unit_selector_tr_key) : nil
  end

  def booking
    !!transaction.booking
  end

  def booking_per_hour
    transaction.booking&.per_hour
  end

  def quantity
    transaction.listing_quantity
  end

  def show_subtotal
    !!transaction.booking || quantity.present? && quantity > 1 || transaction.shipping_price.present?
  end

  def payment
    @payment ||= TransactionService::Transaction.payment_details(transaction)
  end

  def listing_price
    transaction.unit_price
  end

  def start_on
    booking ? transaction.booking.start_on : nil
  end

  def end_on
    booking ? transaction.booking.end_on : nil
  end

  def duration
    booking ? transaction.listing_quantity : nil
  end

  def subtotal
    show_subtotal ? transaction.item_total : nil
  end

  def total
    transaction.payment_total || payment[:total_price]
  end

  def seller_gets
    total - transaction.commission - transaction.buyer_commission
  end

  def fee
    transaction.commission
  end

  def shipping_price
    transaction.shipping_price
  end

  def unit_type
    transaction.unit_type
  end

  def start_time
    booking_per_hour ? transaction.booking.start_time : nil
  end

  def end_time
    booking_per_hour ? transaction.booking.end_time : nil
  end

  def buyer_fee
    transaction.buyer_commission
  end

  def has_buyer_fee
    buyer_fee.present? && buyer_fee > 0
  end

  def has_provider_fee
    fee.present? && fee > 0
  end

  def marketplace_collects
    [fee, buyer_fee].compact.sum
  end

  def messages_and_actions
    @messages_and_actions ||= TransactionViewUtils.merge_messages_and_transitions(
      TransactionViewUtils.conversation_messages(transaction.conversation.messages, community.name_display_type),
      TransactionViewUtils.transition_messages(transaction, transaction.conversation, community.name_display_type))
  end

  def preauthorized?
    transaction.current_state == 'preauthorized'
  end

  def paid?
    transaction.current_state == 'paid'
  end

  def show_next_step?
    preauthorized? || paid?
  end

  def buyer
    transaction.starter
  end

  def buyer_name
    buyer ? PersonViewUtils.person_display_name(buyer, community) : 'X'
  end

  def provider
    transaction.author
  end

  def provider_name
    provider ? PersonViewUtils.person_display_name(provider, community) : 'X'
  end
end
