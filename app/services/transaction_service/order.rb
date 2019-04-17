module TransactionService
  class Order
    attr_reader :community, :tx_params, :listing

    def initialize(community:, tx_params:, listing:)
      @community = community
      @tx_params = tx_params
      @listing = listing
    end

    def price_break_down_locals
      {
         booking: is_booking?,
         quantity: quantity,
         start_on: tx_params[:start_on],
         end_on: tx_params[:end_on],
         duration: quantity,
         listing_price: listing.price,
         localized_unit_type: translate_unit_from_listing,
         localized_selector_label: translate_selector_label_from_listing,
         subtotal: subtotal_to_show,
         shipping_price: shipping_price_to_show,
         total: order_total,
         unit_type: listing.unit_type,
         start_time: tx_params[:start_time],
         end_time: tx_params[:end_time],
         per_hour: tx_params[:per_hour],
         buyer_fee: buyer_fee,
         paypal_in_use: paypal_in_use,
         stripe_in_use: stripe_in_use,
         total_label: nil
      }
    end

    def item_total
      @item_total ||= unit_price * quantity
    end

    def unit_price
      listing.price
    end

    def shipping_total
      @shipping_total ||=
        if tx_params[:delivery] == :shipping
          initial = listing.shipping_price || 0
          additional = listing.shipping_price_additional || 0
          initial + (additional * (quantity - 1))
        else
          0
        end
    end

    def buyer_fee
      return @buyer_fee if defined?(@buyer_fee)

      if stripe_in_use && !paypal_in_use
        commission = stripe_tx_settings[:commission_from_buyer] || 0
        minimum_fee_cents = stripe_tx_settings[:minimum_buyer_transaction_fee_cents] || 0
        relative = (item_total.cents * (commission / 100.0)).to_i
        fee = [relative, minimum_fee_cents].max
        @buyer_fee = MoneyUtil.to_money(fee, listing.currency)
      else
        @buyer_fee = nil
      end
    end

    def order_total
      total = item_total + shipping_total
      total += buyer_fee if buyer_fee
      total
    end

    def quantity
      @quantity ||=
        if is_booking?
          if tx_params[:per_hour]
            DateUtils.duration_in_hours(tx_params[:start_time], tx_params[:end_time])
          else
            DateUtils.duration(tx_params[:start_on], tx_params[:end_on])
          end
        else
          tx_params[:quantity] || 1
        end
    end

    def is_booking?
      @is_booking ||= [ListingUnit::DAY, ListingUnit::NIGHT].include?(listing.quantity_selector) ||
                      (listing.unit_type.to_s == ListingUnit::HOUR && listing.availability == 'booking')
    end

    def translate_unit_from_listing
      listing.unit_type.present? ? ListingViewUtils.translate_unit(listing.unit_type, listing.unit_tr_key) : nil
    end

    def translate_selector_label_from_listing
      listing.unit_type.present? ? ListingViewUtils.translate_quantity(listing.unit_type, listing.unit_selector_tr_key) : nil
    end

    def subtotal_to_show
      item_total if order_total != unit_price
    end

    def shipping_price_to_show
      shipping_total if tx_params[:delivery] == :shipping
    end

    def paypal_in_use
      @paypal_in_use ||= PaypalHelper.user_and_community_ready_for_payments?(listing.author_id, community.id)
    end

    def stripe_in_use
      @stripe_in_use ||= StripeHelper.user_and_community_ready_for_payments?(listing.author_id, community.id)
    end

    def stripe_tx_settings
      @stripe_tx_settings ||=
        Maybe(TransactionService::API::Api.settings.get(community_id: community.id, payment_gateway: :stripe, payment_process: :preauthorize))
        .select { |result| result[:success] }
        .map { |result| result[:data] }
        .or_else({})
    end
  end
end

