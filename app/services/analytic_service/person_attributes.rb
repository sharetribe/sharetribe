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
        result[ADMIN_CREATED_FILTER] =  community.custom_fields.any?
        result[ADMIN_CREATED_LISTING] = person.listings.where(community_id: community.id).any?
        result[ADMIN_INVITED_USER] = person.invitations.where(community_id: community.id).any?
        result[ADMIN_CONFIGURED_FACEBOOK_CONNECT] = community.facebook_connect_id.present? &&
                                                    community.facebook_connect_secret.present?
        result[ADMIN_CONFIGURED_OUTGOING_EMAIL] = community.marketplace_sender_emails.verified.any?
        result[ORDER_TYPE_ONLINE_PAYMENT] = transaction_processes_by_type(community, :preauthorize)
        result[ORDER_TYPE_NO_ONLINE_PAYMENTS] = transaction_processes_by_type(community, :none)
        result[ADMIN_CONFIGURED_PAYPAL_ACOUNT] = configured_paypal_account(community)
        result[ADMIN_CONFIGURED_PAYPAL_FEES] = configured_fees(community, 'paypal')
        result[ADMIN_CONFIGURED_STRIPE_API] = configured_stripe_account(community)
        result[ADMIN_CONFIGURED_STRIPE_FEES] = configured_fees(community, 'stripe')
        result[PAYMENT_PROVIDERS_AVAILABLE] = payment_providers(result)
      end
      result[ADMIN_CONFIRMED_EMAIL] = person.emails.confirmed.any?
      result[ADMIN_DELETED_MARKETPLACE] = Community.where(id: person.community_memberships.accepted.admin
                                                          .pluck(:community_id)).where(deleted: true).any?
      result.stringify_keys
    end

    private

    def payment_providers(attrs)
      result = []
      result.push 'paypal' if attrs[ADMIN_CONFIGURED_PAYPAL_ACOUNT]
      result.push 'stripe' if attrs[ADMIN_CONFIGURED_STRIPE_API]
      result.push 'none' if result.empty?
      result.join(',')
    end

    def transaction_processes_by_type(community, process_type)
      result = transaction_processes(community)
      if result.data
        result.data.select{|x| x[:process] == process_type}.any?
      else
        false
      end
    end

    def transaction_processes(community)
      @transaction_processes ||= TransactionService::API::Api.processes.get(community_id: community.id)
    end

    def configured_paypal_account(community)
      result = PaypalService::API::Api.accounts.get(community_id: community.id)
      result.data ? result.data[:state] == :verified : false
    end

    def configured_stripe_account(community)
      StripeHelper.stripe_active?(community.id)
    end

    def configured_fees(community, payment_gateway)
      result = TransactionService::API::Api.settings.get_active_by_gateway(community_id: community.id,
                                                                           payment_gateway: payment_gateway)
      result.data ? payment_fees?(result.data) : false
    end

    def payment_fees?(data)
      data[:commission_from_seller].present? && data[:minimum_transaction_fee_cents].present?
    end
  end
end
