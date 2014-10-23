module PaypalService::Store::Token
  PaypalTokenModel = ::PaypalToken

  module Entity
    Token = EntityUtils.define_builder(
      [:community_id, :mandatory, :fixnum],
      [:token, :string, :mandatory],
      [:transaction_id, :fixnum, :mandatory],
      [:merchant_id, :string, :mandatory]
    )

    module_function

    def from_model(model)
      Token.call(EntityUtils.model_to_hash(model))
    end
  end


  module_function

  def create(community_id, token, transaction_id, merchant_id)
    PaypalToken.create!({
        community_id: community_id,
        token: token,
        transaction_id: transaction_id,
        merchant_id: merchant_id
    })
  end

  def delete(community_id, token)
    PaypalToken.where(community_id: community_id, token: token).destroy_all
  end

  def get(community_id, token)
    Maybe(PaypalToken.where(token: token, community_id: community_id).first)
      .map { |model| Entity.from_model(model) }
      .or_else(nil)
  end

  def transaction_id_for(community_id, token)
    PaypalToken.where(token: token, community_id: community_id).pluck(:transaction_id).first
  end
end
