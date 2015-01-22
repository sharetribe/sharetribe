module PaypalService::Store::PaypalAccount
  PaypalAccountModel = ::PaypalAccount
  OrderPermissionModel = ::OrderPermission

  PaypalAccount = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string], # optional for admin accounts
    [:email, :string],
    [:payer_id, :string]
  )

  OrderPermission = EntityUtils.define_builder(
    [:request_token, :mandatory, :string],
    [:paypal_username_to, :mandatory, :string]
  )

  module_function

  def create(opts, permission_opts)
    account = HashUtils.compact(PaypalAccount.call(opts))
    permission = HashUtils.compact(OrderPermission.call(permission_opts))

    account_model = PaypalAccountModel.create!(account)
    permission_model = OrderPermissionModel.create!(permission.merge(paypal_account_id: account_model.id))

    from_model(account_model)
  end

  ## Privates

  def from_model(model)
    Maybe(model)
      .map { |m| PaypalAccount.call(EntityUtils.model_to_hash(m)) }
      .or_else(nil)
  end
end
