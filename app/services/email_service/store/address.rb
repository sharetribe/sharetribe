module EmailService::Store::Address

  Address = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:name, :string, :optional],
    [:email, :string, :mandatory],

    # TODO
    # [:verification_status, one_of: [:none, :requested, :verified, :expired]],
    # [:verification_requested_at, :time, :optional],
    # [:updated_at, :time, :mandatory]
  )

  module_function

  def get(community_id:)
    from_model(find_model(community_id: community_id))
  end

  def create(community_id:, opts:)
    address = Address.call(opts.merge(community_id: community_id))
    from_model(MarketplaceSenderEmail.create!(address))
  end

  def find_model(community_id:)
    MarketplaceSenderEmail.where(community_id: community_id).first
  end

  def from_model(model)
    Maybe(model).map { |m|
      Address.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end

end
