module EmailService::Store::Address

  NewAddress = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:name, :string, :optional],
    [:email, :string, :mandatory],
    [:verification_status, :to_symbol, one_of: [:none, :requested, :verified, :expired]]
  )

  Address = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
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

  def get(community_id:, id:)
    from_model(MarketplaceSenderEmail.where(community_id: community_id, id: id).first)
  end

  def get_latest(community_id:)
    from_model(
      MarketplaceSenderEmail
      .where(community_id: community_id)
      .order('created_at DESC')
      .limit(1)
      .first)
  end

  def load_all(limit:, offset:)
    MarketplaceSenderEmail
      .limit(limit)
      .offset(offset)
      .map { |m| from_model(m) }
  end

  def create(community_id:, address:)
    address = NewAddress.call(
      address.merge(
      community_id: community_id)
    )
    from_model(MarketplaceSenderEmail.create!(HashUtils.compact(address)))
  end

  def set_verification_requested(community_id:, id:)
    Maybe(MarketplaceSenderEmail.where(community_id: community_id, id: id).first)
      .update_attributes(
        verification_requested_at: Time.now,
        verification_status: :requested)
      .or_else(nil)
  end

  def set_verification_status(ids:, status:)
    if ids.present?
      MarketplaceSenderEmail.where(id: ids)
        .update_all(verification_status: status, updated_at: Time.now)
    end
  end

  def touch(ids:)
    if ids.present?
      MarketplaceSenderEmail.where(id: ids)
        .update_all(updated_at: Time.now)
    end
  end

  def update(community_id:, id:, name:)
    Maybe(MarketplaceSenderEmail.where(community_id: community_id, id: id).first)
      .update_attributes(name:  name).or_else(nil)
  end

  ## Privates

  def from_model(model)
    Maybe(model).map { |m|
      Address.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end
end
