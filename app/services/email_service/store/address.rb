module EmailService::Store::Address

  NewAddress = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:name, :string, :optional],
    [:email, :string, :mandatory],
    [:verification_status, :to_symbol, one_of: [:none, :requested, :verified, :expired]]
  )

  Address = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:name, :string, :optional],
    [:email, :string, :mandatory],
    [:verification_status, :to_symbol, one_of: [:none, :requested, :verified, :expired]],
    [:verification_requested_at, :time, :optional],
    [:updated_at, :time, :mandatory]
  )

  module_function

  def get_latest_verified(community_id:)
    from_model(
      MarketplaceSenderEmail
      .where(community_id: community_id, verification_status: :verified)
      .order('created_at DESC')
      .limit(1)
      .first)
  end

  def get_latest(community_id:)
    from_model(
      MarketplaceSenderEmail
      .where(community_id: community_id)
      .order('created_at DESC')
      .limit(1)
      .first)
  end

  def create(community_id:, address:)
    address = Address.call(
      address.merge(
      community_id: community_id)
    )
    from_model(MarketplaceSenderEmail.create!(HashUtils.compact(address)))
  end

  def from_model(model)
    Maybe(model).map { |m|
      Address.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end
end
