module AnalyticService
  class PersonAttributes
    attr_reader :person, :community

    def initialize(person:, community_id:)
      @person = person
      @community = Community.find_by(id: community_id)
    end

    def attributes
      result = {}
      if community
        result[INFO_MARKETPLACE_IDENT] = community.ident
      end
      result.stringify_keys
    end

    private

    def payment_providers(attrs)
      result = []
      stripe_mode = StripeService::API::API.wrapper.charges_mode(community.id)
      if TransactionService::AvailableCurrencies.stripe_allows_country_and_currency?(community.country,
                                                                                     community.currency,
                                                                                     stripe_mode)
        result.push 'stripe'
      end
      if TransactionService::AvailableCurrencies.paypal_allows_country_and_currency?(community.country,
                                                                                     community.currency)
        result.push 'paypal'
      end
      result.push 'none' if result.empty?
      result.join(',')
    end

    def listing_shapes_online_payment
      transaction_processes_by_type(community, listing_shapes_transaction_process_ids, :preauthorize)
    end

    def listing_shapes_no_online_payment
      transaction_processes_by_type(community, listing_shapes_transaction_process_ids, :none)
    end

    def listing_shapes_transaction_process_ids
      listing_shapes.map{|s| s.transaction_process_id}
    end

    def listing_shapes
      @listing_shapes ||= community.shapes
    end

    def transaction_processes_by_type(community, ids, process_type)
      result = transaction_processes(community)
      if result.data
        result.data.select{|x| ids.include?(x.id) && x.process == process_type}.any?
      else
        false
      end
    end

    def transaction_processes(community)
      @transaction_processes ||= TransactionService::API::API.processes.get(community_id: community.id)
    end

    def configured_paypal_account(community)
      result = PaypalService::API::API.accounts.get(community_id: community.id)
      result.data ? result.data[:state] == :verified : false
    end

    def configured_stripe_account(community)
      StripeHelper.stripe_active?(community.id)
    end

    def configured_fees(community, payment_gateway)
      result = TransactionService::API::API.settings.get_active_by_gateway(community_id: community.id,
                                                                           payment_gateway: payment_gateway)
      result.data ? payment_fees?(result.data) : false
    end

    def payment_fees?(data)
      data[:commission_from_seller].present? && data[:minimum_transaction_fee_cents].present?
    end
  end
end
