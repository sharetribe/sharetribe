module StripeService::API

  class Accounts
    def get(community_id:, person_id: nil)
      Result::Success.new(stripe_accounts_store.get(person_id: person_id, community_id: community_id))
    end

    def get_active_users(community_id:)
      stripe_accounts_store.get_active_users(community_id: community_id)
    end

    def create(community_id:, person_id:, body:)
      metadata = {sharetribe_community_id: community_id, sharetribe_person_id: person_id, sharetribe_mode: stripe_api.charges_mode(community_id)}
      result = stripe_api.register_seller(community: community_id, account_info: body, metadata: metadata)
      data = body.merge(stripe_seller_id: result.id, community_id: community_id, person_id: person_id)
      Result::Success.new(stripe_accounts_store.create(opts: data))
    rescue => e
      Result::Error.new(e.message)
    end

    def create_bank_account(community_id:, person_id:, body:)
      account = stripe_accounts_store.get(person_id: person_id, community_id: community_id).to_hash
      result = stripe_api.create_bank_account(community: community_id, account_info: account.merge(body))
      data = body.merge(stripe_bank_id: result.id)
      Result::Success.new(stripe_accounts_store.update_bank_account(community_id: community_id, person_id: person_id, opts: data))
    rescue => e
      Result::Error.new(e.message)
    end

    def create_customer(community_id:, person_id:, body:)
      data = { community_id: community_id, person_id: person_id}
      Result::Success.new(stripe_accounts_store.create_customer(opts: data))
    rescue => e
      Result::Error.new(e.message)
    end

    def update_account(community_id:, person_id:, token:)
      data = { community_id: community_id, person_id: person_id}
      account = stripe_accounts_store.get(person_id: person_id, community_id: community_id).to_hash
      stripe_api.update_account(community: community_id, account_id: account[:stripe_seller_id], token: token)
      Result::Success.new(account)
    rescue => e
      Result::Error.new(e.message)
    end

    def update_field(community_id:, person_id:, field:, value:)
      Result::Success.new(stripe_accounts_store.update_field(community_id: community_id, person_id: person_id, field: field, value: value))
    rescue => e
      Result::Error.new(e.message)
    end

    def send_verification(community_id:, person_id:, personal_id_number:, file:)
      account = stripe_accounts_store.get(community_id: community_id, person_id: person_id)
      stripe_api.send_verification(community: community_id, account_id: account[:stripe_seller_id], personal_id_number: personal_id_number, file_path: file)
      Result::Success.new(account)
    rescue => e
      Result::Error.new(e.message)
    end

    def destroy(community_id:, person_id:)
      Result::Success.new(stripe_accounts_store.destroy(community_id: community_id, person_id: person_id))
    rescue => e
      Result::Error.new(e.message)
    end

    def delete_seller_account(community_id:, person_id: nil)
      account = stripe_accounts_store.get(person_id: person_id, community_id: community_id)
      if account && account[:stripe_seller_id].present?
        res = Result::Success.new(stripe_api.delete_account(community: community_id, account_id: account[:stripe_seller_id]))
        stripe_accounts_store.destroy(person_id: person_id, community_id: community_id)
        res
      else
        Result::Success.new()
      end
    rescue => e
      Result::Error.new(e.message)
    end

    private

    def stripe_api
      StripeService::API::Api.wrapper
    end

    def stripe_accounts_store
      StripeService::Store::StripeAccount
    end
  end
end
