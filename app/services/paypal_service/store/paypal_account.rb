module PaypalService::Store::PaypalAccount
  PaypalAccountModel = ::PaypalAccount
  OrderPermissionModel = ::OrderPermission

  PaypalAccount = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string], # optional for admin accounts
    [:email, :string],
    [:payer_id, :string],
    [:order_permission_state, one_of: [:not_verified, :verified, nil]],
    [:billing_agreement_state, one_of: [:not_verified, :verified, nil]],
  )

  COMPUTED_PAYPAL_ACCOUNT_VALUES = [:order_permissions_state, :billing_agreement_state]

  OrderPermissionCreate = EntityUtils.define_builder(
    [:paypal_username_to, :mandatory, :string],
    [:request_token, :mandatory, :string]
  )

  OrderPermissionUpdate = EntityUtils.define_builder(
    [:verification_code, :optional, :string],
    [:scope, :optional, :string]
  )

  BillingAgreement = EntityUtils.define_builder(
    [:request_token, :string],
    [:paypal_username_to, :string]
  )

  module_function

  def create(opts)
    account = HashUtils.compact(PaypalAccount.call(opts))
    permission = HashUtils.compact(OrderPermissionCreate.call(opts))

    account_model = PaypalAccountModel.create!(account)
    permission_model = OrderPermissionModel.create!(permission.merge(paypal_account_id: account_model.id))

    from_model(account_model)
  end

  def update(opts)
    account_model = find_model(opts[:person_id], opts[:community_id])

    raise "Can not find Paypal account for person_id #{opts[:person_id]} and community_id #{opts[:community_id]}" unless account_model

    account_model.update_attributes(filter_computed(HashUtils.compact(PaypalAccount.call(opts))))
    account_model.order_permission.update_attributes(HashUtils.compact(OrderPermissionUpdate.call(opts)))
    account_model = update_or_create_billing_agreement(account_model, opts)

    from_model(account_model)
  end

  ## Privates

  def update_or_create_billing_agreement(account_model, opts)
    billing_agreement_opts = to_billing_agreement(opts)
    if account_model.billing_agreement.nil?
      # create
      account_model.create_billing_agreement(billing_agreement_opts)
    else
      # update
      account_model.billing_agreement.update_attributes(billing_agreement_opts)
    end
    account_model
  end

  def to_billing_agreement(opts)
    renames = {
      billing_agreement_request_token: :request_token,
      billing_agreement_paypal_username_to: :paypal_username_to
    }

    renames_opts = HashUtils.rename_keys(renames, opts)
    HashUtils.compact(BillingAgreement.call(renames_opts))
  end

  # Filter computed values from the PaypalAccount entity. We don't let users to update these values
  def filter_computed(opts)
    opts.except(*COMPUTED_PAYPAL_ACCOUNT_VALUES)
  end

  def find_model(person_id, community_id)
    PaypalAccountModel.where(person_id: person_id, community_id: community_id).first
  end

  def from_model(model)
    Maybe(model)
      .map { |m|
        hash = EntityUtils.model_to_hash(m)
        hash[:order_permission_state] =
          Maybe(m).order_permission.verification_code.map { |code| :verified }.or_else(:not_verified)
        hash[:billing_agreement_state] =
          Maybe(m).billing_agreement.billing_agreement_id.map { |code| :verified }.or_else(:not_verified)
        PaypalAccount.call(hash)
      }
      .or_else(nil)
  end
end
