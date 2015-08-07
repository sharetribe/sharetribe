module EmailService::Store::Address

  Address = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:name, :string, :optional],
    [:email, :string, :mandatory],
    [:verification_status, :to_symbol, one_of: [:none, :requested, :verified, :expired]],
    [:updated_at, :time, :optional] # Optional, no need to pass it when creating

    # TODO
    # [:verification_requested_at, :time, :optional],

  )

  module_function

  def get(community_id:, email:)
    from_model(MarketplaceSenderEmail.where(community_id: community_id, email: email).first)
  end

  def get_all(community_id:)
    MarketplaceSenderEmail.where(community_id: community_id).map { |m|
      from_model(m)
    }
  end

  def create(community_id:, address:)
    address = Address.call(
      address.merge(
      community_id: community_id,
      verification_status: :verified # TODO At this point we expect
                                     # that all saved emails are
                                     # verified. This will be changed
                                     # soon.
    ))
    from_model(MarketplaceSenderEmail.create!(HashUtils.compact(address)))
  end

  def from_model(model)
    Maybe(model).map { |m|
      Address.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end
end
