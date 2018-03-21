module TransactionService::Store::ProcessToken

  ProcessTokenModel = ::TransactionProcessToken

  ProcessToken = EntityUtils.define_builder(
    [:process_token, :mandatory, :uuid],
    [:community_id, :mandatory, :fixnum],
    [:paypal_token, :string],
    [:transaction_id, :fixnum],
    [:op_completed, :to_bool],
    [:op_name, :mandatory, :to_symbol],
    [:op_input, :enumerable],
    [:op_output])


  module_function

  def create(community_id:, transaction_id:, op_name:, op_input: [])
    create_unique({
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input
      })
  end

  def update_to_completed(process_token:, op_output:)
    by_process_token(process_token).first!
      .update_attributes(op_completed: true, op_output: YAML.dump(op_output))
  end

  def get_by_transaction(community_id:, transaction_id:, op_name:)
    Maybe(ProcessTokenModel.where(
        transaction_id: transaction_id,
        community_id: community_id,
        op_name: op_name
      ).first)
      .map { |model| from_model(model) }
      .or_else(nil)
  end

  def get_by_process_token(process_token)
    Maybe(by_process_token(process_token).first)
      .map { |model| from_model(model) }
      .or_else(nil)
  end


  # Privates

  def by_process_token(process_token)
    ProcessTokenModel.where(process_token: UUIDUtils.raw(process_token))
  end

  def gen_process_token_uuid
    UUIDUtils.create_raw
  end

  def create_unique(info)
    model =
      begin
        ProcessTokenModel.create!(
        info.merge({
            process_token: gen_process_token_uuid,
            op_input: YAML.dump(info[:op_input])
          }))
      rescue ActiveRecord::RecordNotUnique
        nil
      end

    Maybe(model).map { |m| from_model(m) }.or_else(nil)
  end

  def from_model(model)
    ::Transaction.name # load the class
    model_hash = EntityUtils.model_to_hash(model)
    model_hash[:op_input] = YAML.load(model_hash[:op_input]) unless model_hash[:op_input].nil?
    model_hash[:op_output] = YAML.load(model_hash[:op_output]) unless model_hash[:op_output].nil?
    model_hash[:process_token] = UUIDUtils.parse_raw(model_hash[:process_token])

    ProcessToken.call(model_hash)
  end

end
