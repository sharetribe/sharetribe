module StripeService::API

  class Accounts
    def get(community_id:, person_id: nil)
      Result::Success.new(accounts_store.get(person_id: person_id, community_id: community_id))
    end

    def create(community_id:, person_id:, body:)
      result = stripe_api.register_seller(community_id, body)
      data = body.merge(stripe_seller_id: result.id, community_id: community_id, person_id: person_id)
      Result::Success.new(accounts_store.create(opts: data))
    rescue => e
      Result::Error.new(e.message)
    end

    def create_bank_account(community_id:, person_id:, body:)
      account = accounts_store.get(person_id: person_id, community_id: community_id).to_hash
      result = stripe_api.create_bank_account(community_id, account.merge(body))
      data = body.merge(stripe_bank_id: result.id)
      Result::Success.new(accounts_store.update_bank_account(community_id: community_id, person_id: person_id, opts: data))
    rescue => e
      Result::Error.new(e.message)
    end

    def create_customer(community_id:, person_id:, body:)
      data = { community_id: community_id, person_id: person_id}
      Result::Success.new(accounts_store.create_customer(opts: data))
    rescue => e
      Result::Error.new(e.message)
    end

    def update_address(community_id:, person_id:, body:)
      data = { community_id: community_id, person_id: person_id}
      account = accounts_store.get(person_id: person_id, community_id: community_id).to_hash
      stripe_api.update_address(community_id, account[:stripe_seller_id], body)
      Result::Success.new(accounts_store.update_address(community_id: community_id, person_id: person_id, opts: body))
    rescue => e
      raise e
      Result::Error.new(e.message)
    end

    def update_field(community_id:, person_id:, field:, value:)
      Result::Success.new(accounts_store.update_field(community_id: community_id, person_id: person_id, field: field, value: value))
    rescue => e
      Result::Error.new(e.message)
    end

    def send_verification(community_id:, person_id:, personal_id_number:, file:)
      account = accounts_store.get(community_id: community_id, person_id: person_id)
      stripe_api.send_verification(community_id, account[:stripe_seller_id], personal_id_number, file)
      Result::Success.new(accounts_store.update_field(community_id: community_id, person_id: person_id, field: :personal_id_number, value: personal_id_number))
    rescue => e
      Result::Error.new(e.message)
    end

    private

    def stripe_api
      StripeService::API::Api.wrapper
    end

    def accounts_store
      StripeService::Store::StripeAccount
    end
  end
end
