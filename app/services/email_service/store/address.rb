module EmailService::Store::Address

  Address = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:name, :string, :optional],
    [:email, :string, :mandatory],
    [:verification_status, :to_symbol, one_of: [:none, :requested, :verified, :expired]],

    # TODO
    # [:verification_requested_at, :time, :optional],
    # [:updated_at, :time, :mandatory]
  )

  module_function

  def get(community_id:)
    from_model(MarketplaceSenderEmail.where(community_id: community_id).first)
  end

  def get_all(community_id:)
    MarketplaceSenderEmail.where(community_id: community_id).map { |m|
      from_model(m)
    }
  end

  def create(community_id:, opts:)
    address = Address.call(
      opts.merge(
      community_id: community_id,
      verification_status: :verified # TODO At this point we expect
                                     # that all saved emails are
                                     # verified. This will be changed
                                     # soon.
    ))
    from_model(MarketplaceSenderEmail.create!(address))
  end

  def from_model(model)
    Maybe(model).map { |m|
      Address.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end
end
