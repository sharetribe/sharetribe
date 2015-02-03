module PaypalService::Store::PaypalAccount
  PaypalAccountModel = ::PaypalAccount
  OrderPermissionModel = ::OrderPermission

  PaypalAccountCreate = EntityUtils.define_builder(
    # Mandatory
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string],
    [:order_permission_request_token, :mandatory, :string],
    [:order_permission_paypal_username_to, :mandatory, :string],

    # Optional
    [:active, one_of: [true, false, nil]],
    [:email, :string],
    [:payer_id, :string],

    [:order_permission_verification_code, :string],
    [:order_permission_scope, :string],

    [:billing_agreement_billing_agreement_id, :string],
    [:billing_agreement_paypal_username_to, :string],
    [:billing_agreement_request_token, :string]
  )

  PaypalAccountUpdate = EntityUtils.define_builder(
    [:active, one_of: [true, false, nil]],
    [:email, :string],
    [:payer_id, :string],
    [:order_permission_verification_code, :string],
    [:order_permission_scope, :string],
    [:billing_agreement_billing_agreement_id, :string],
    [:billing_agreement_paypal_username_to, :string],
    [:billing_agreement_request_token, :string]
  )

  PaypalAccount = EntityUtils.define_builder(
    [:active, :mandatory, :to_bool],
    [:community_id, :fixnum],
    [:person_id, :string],
    [:email, :string],
    [:payer_id, :string],
    [:state, one_of: [:not_verified, :verified]],
    [:order_permission_state, one_of: [:not_verified, :pending, :verified]],
    [:billing_agreement_state, one_of: [:not_verified, :pending, :verified]],
    [:billing_agreement_billing_agreement_id, :string]
  )

  # Rename map for PaypalAccount values that are stored to order_permissions table
  ORDER_PERMISSIONS_MAP = {
    order_permission_request_token: :request_token,
    order_permission_paypal_username_to: :paypal_username_to,
    order_permission_verification_code: :verification_code,
    order_permission_scope: :scope
  }

  # Rename map for PaypalAccount values that are stored to billing_agreement table
  BILLING_AGREEMENT_MAP = {
    billing_agreement_billing_agreement_id: :billing_agreement_id,
    billing_agreement_paypal_username_to: :paypal_username_to,
    billing_agreement_request_token: :request_token
  }

  module_function

  def create(opts:)
    entity = PaypalAccountCreate.call(opts)
    account = select_paypal_account_values(entity)
    order_permission = select_order_permission_values(entity)

    account_model = PaypalAccountModel.create!(account)
    account_model.create_order_permission(order_permission)
    account_model = update_or_create_billing_agreement(account_model, select_billing_agreement_values(entity))

    from_model(Maybe(account_model))
  end

  def update(community_id:, person_id:nil, opts:)
    entity = PaypalAccountUpdate.call(opts)

    maybe_model = find_model(person_id: person_id, community_id: community_id)

    case maybe_model
    when Some
      account_model = maybe_model.get
      account_model.update_attributes(select_paypal_account_values(entity))
      account_model.order_permission.update_attributes(select_order_permission_values(entity))
      account_model = update_or_create_billing_agreement(account_model, select_billing_agreement_values(entity))

      from_model(Maybe(account_model))
    else
      raise ArgumentError.new("Can not find Paypal account for person_id #{person_id} and community_id #{community_id}") unless account_model
    end

  end

  def delete_billing_agreement(person_id:, community_id:)
    maybe_account = find_model(person_id: person_id, community_id: community_id)
    maybe_account.billing_agreement.each { |billing_agreement| billing_agreement.destroy }
  end

  def delete_billing_agreement_by_payer_and_agreement_id(payer_id:, billing_agreement_id:)
    maybe_billing_agreement = find_billing_agreement_by_payer_and_agreement_id(payer_id: payer_id, billing_agreement_id: billing_agreement_id)
    maybe_billing_agreement.each { |billing_agreement| billing_agreement.destroy }
  end

  def delete(person_id:nil, community_id:)
    find_model(person_id: person_id, community_id: community_id).each { |account| account.destroy }
  end

  def get(person_id:nil, community_id:)
    from_model(find_model(person_id: person_id, community_id: community_id))
  end

  def get_by_payer_id(payer_id:, community_id:)
    from_model(find_model_by_payer_and_community(payer_id: payer_id, community_id: community_id))
  end

  ## Privates

  def update_or_create_billing_agreement(account_model, opts)
    return account_model if opts.empty?

    if account_model.billing_agreement.nil?
      # create
      account_model.create_billing_agreement(opts)
    else
      # update
      account_model.billing_agreement.update_attributes(opts)
    end
    account_model
  end

  def select_paypal_account_values(opts)
    filter_keys = BILLING_AGREEMENT_MAP.keys.concat(ORDER_PERMISSIONS_MAP.keys)
    HashUtils.compact(opts.except(*filter_keys))
  end

  def select_billing_agreement_values(opts)
    sub_and_rename(opts, BILLING_AGREEMENT_MAP)
  end

  def select_order_permission_values(opts)
    sub_and_rename(opts, ORDER_PERMISSIONS_MAP)
  end

  def find_model(person_id:nil, community_id:)
    Maybe(
      PaypalAccountModel.where(person_id: person_id, community_id: community_id)
      .eager_load([:order_permission, :billing_agreement])
      .first
    )
  end

  def find_billing_agreement_by_payer_and_agreement_id(payer_id:, billing_agreement_id:)
    Maybe(
      BillingAgreement
      .joins(:paypal_account)
      .where(
        {
          billing_agreement_id: billing_agreement_id,
          paypal_accounts: {payer_id: payer_id}
        }).first
    )
  end

  def find_model_by_payer(payer_id:)
    Maybe(
      PaypalAccountModel.where(payer_id: payer_id)
      .eager_load([:order_permission, :billing_agreement])
    )
  end

  def find_model_by_payer_and_community(payer_id:, community_id:)
    Maybe(
      PaypalAccountModel.where("community_id = ? AND payer_id = ? AND person_id IS NOT NULL", community_id, payer_id)
      .eager_load([:order_permission, :billing_agreement])
      .first
    )
  end

  # Maybe(model) -> entity
  def from_model(model)
    model
      .map { |m|
        hash = EntityUtils.model_to_hash(m)

        hash[:order_permission_state] =
          Maybe(m).order_permission.map { |perm|
          if perm.verification_code
            :verified
          elsif perm.request_token
            :pending
          else
            :not_verified
          end
        }.or_else(:not_verified)

        hash[:billing_agreement_state] =
          Maybe(m).billing_agreement.map { |ba|
          if ba.billing_agreement_id
            :verified
          elsif ba.request_token
            :pending
          else
            :not_verified
          end
        }.or_else(:not_verified)

        hash[:state] = account_state(hash)

        hash[:billing_agreement_billing_agreement_id] =
          Maybe(m).billing_agreement.billing_agreement_id.or_else(nil)
        PaypalAccount.call(hash)
      }
      .or_else(nil)
  end

  def account_state(entity)
    case [entity[:person_id], entity[:order_permission_state], entity[:billing_agreement_state]]
    when matches([nil, :verified])
      # verified community account
      :verified
    when matches([__, :verified, :verified])
      # verified personal account
      :verified
    else
      :not_verified
    end
  end

  def sub_and_rename(h, rename_map)
    sub = HashUtils.sub(h, *rename_map.keys)
    renamed = HashUtils.rename_keys(rename_map, sub)
    HashUtils.compact(renamed)
  end
end
