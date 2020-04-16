class Admin2::TransactionsPresenter
  include Collator

  private

  attr_reader :service

  public

  def initialize(params, service)
    @params = params
    @service = service
  end

  delegate :transactions, :transaction, :community, to: :service, prefix: false

  FILTER_STATUSES = %w[free confirmed paid canceled preauthorized rejected
                       payment_intent_requires_action payment_intent_action_expired
                       disputed refunded dismissed]

  def sorted_statuses
    statuses = FILTER_STATUSES
    statuses.map {|status|
      ["#{I18n.t("admin.communities.transactions.status_filter.#{status}")} (#{count_by_status(status)})", status]
    }.sort_by{|translation, _status| collator.get_sort_key(translation) }
  end

  def count_by_status(status = nil)
    scope = Transaction.exist.by_community(community.id)
    if status.present?
      scope.where(current_state: status).count
    else
      scope.count
    end
  end

  def has_search?
    @params[:q].present? || @params[:status].present?
  end

  def show_link?(tx)
    exclude = %w[pending payment_intent_requires_action payment_intent_action_expired]
    !exclude.include?(tx.current_state)
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
    buyer_fee.present? && buyer_fee.positive?
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
      TransactionViewUtils.transition_messages(transaction, transaction.conversation, community.name_display_type)).reverse
  end

  def preauthorized?
    transaction.current_state == 'preauthorized'
  end

  def paid?
    transaction.current_state == 'paid'
  end

  def disputed?
    transaction.current_state == 'disputed'
  end

  def show_next_step?
    preauthorized? || paid? || disputed?
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

  def completed?
    %w[confirmed canceled refunded].include?(transaction.current_state)
  end

  def shipping?
    transaction.delivery_method == 'shipping'
  end

  def pickup?
    transaction.delivery_method == 'pickup'
  end

  def shipping_address
    return @shipping_address if defined?(@shipping_address)

    @shipping_address = nil
    fields = %i[name phone street1 street2 postal_code city state_or_province country]
    if transaction.shipping_address
      address = transaction.shipping_address.slice(*fields)
      if address.values.any?
        address[:country] ||= CountryI18nHelper.translate_country(shipping_address[:country_code])
        @shipping_address = fields.map{|field| address[field]}.select{|x| x.present?}.join(', ')
      end
    end
    @shipping_address
  end

  def show_transactions_export?
    !personal? && !has_search?
  end

  def personal?
    service.personal
  end
end
