module TransactionService::Store::TransactionProcess

  TransactionProcessModel = ::TransactionProcess

  NewTransactionProcess = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:author_is_seller, :to_bool, :mandatory],
    [:process, one_of: [:none, :preauthorize, :postpay]])

  TransactionProcess = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:community_id, :fixnum, :mandatory],
    [:author_is_seller, :to_bool, :mandatory],
    [:process, :to_symbol, one_of: [:none, :preauthorize, :postpay]])

  module_function

  def get_all(community_id:)
    TransactionProcessModel.where(community_id: community_id)
      .map { |m| from_model(m) }
  end

  def get(community_id:, process_id:)
    Maybe(TransactionProcessModel.where(community_id: community_id, id: process_id).first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def create(community_id:, opts:)
    from_model(
      TransactionProcessModel.create!(
        NewTransactionProcess.call(opts.merge(community_id: community_id))))
  end


  # private

  def from_model(model)
    Maybe(model)
      .map { |m| TransactionProcess.call(EntityUtils.model_to_hash(m)) }
      .or_else(nil)
  end

end
