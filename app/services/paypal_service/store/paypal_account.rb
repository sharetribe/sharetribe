#
# PayPalAccount Store wraps ActiveRecord models and stores accounts to the database.
#
module PaypalService::Store::PaypalAccount
  PaypalAccountModel = ::PaypalAccount
  OrderPermissionModel = ::OrderPermission

  PaypalAccountCreate = EntityUtils.define_builder(
    # Mandatory
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string],
    [:order_permission_paypal_username_to, :mandatory, :string],

    # Optional
    [:order_permission_request_token, :string],
    [:active, one_of: [true, false, nil]],
    [:email, :string],
    [:payer_id, :string],

    [:order_permission_verification_code, :string],
    [:order_permission_scope, :string],
    [:order_permission_onboarding_id, :string],

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
    [:order_permission_permissions_granted, :bool],
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
    [:state, one_of: [:not_connected, :connected, :verified]],
    [:order_permission_state, one_of: [:not_verified, :pending, :verified]],
    [:billing_agreement_state, one_of: [:not_verified, :pending, :verified]],
    [:billing_agreement_billing_agreement_id, :string]
  )

  # PaypalAccount is composed of three tables that are flatted together:
  #
  # - paypal_accounts
  # - order_permissions
  # - billing_agreements
  #
  # This helper has some utility functions to deal with the flatted values
  #
  module FlattingHelper

    # Rename map for PaypalAccount values that are stored to order_permissions table
    ORDER_PERMISSIONS_MAP = {
      order_permission_request_token: :request_token,
      order_permission_paypal_username_to: :paypal_username_to,
      order_permission_verification_code: :verification_code,
      order_permission_scope: :scope,
      order_permission_onboarding_id: :onboarding_id,
      order_permission_permissions_granted: :permissions_granted
    }

    # Rename map for PaypalAccount values that are stored to billing_agreement table
    BILLING_AGREEMENT_MAP = {
      billing_agreement_billing_agreement_id: :billing_agreement_id,
      billing_agreement_paypal_username_to: :paypal_username_to,
      billing_agreement_request_token: :request_token
    }

    module_function

    def select_paypal_account_values(opts)
      filter_keys = BILLING_AGREEMENT_MAP.keys.concat(ORDER_PERMISSIONS_MAP.keys)
      opts.except(*filter_keys)
    end

    def select_billing_agreement_values(opts)
      sub_and_rename(opts, BILLING_AGREEMENT_MAP)
    end

    def select_order_permission_values(opts)
      sub_and_rename(opts, ORDER_PERMISSIONS_MAP)
    end

    def sub_and_rename(h, rename_map)
      sub = HashUtils.sub(h, *rename_map.keys)
      HashUtils.rename_keys(rename_map, sub)
    end
  end

  # There are a couple of combinations of fields that result a unique row from the
  # paypal_accounts table. This class enforces correct usage and ensures the right unique row
  # is returned.
  #
  # - Personal account: person_id, community_id, payer_id
  # - Pending personal account: person_id, community_id, order_permission_request_token
  # - Active personal account: person_id, community_id, active: true
  # - Community account: person_id: nil, community_id, payer_id
  # - Pending community account: person_id: nil, community_id:, order_permission_request_token
  # - Active community account: person_id: nil, community_id, active: true
  #
  class PaypalAccountFinder

    def find(person_id: nil, community_id:, payer_id:)
      query_one(person_id: person_id, community_id: community_id, payer_id: payer_id)
    end

    def find_pending(person_id: nil, community_id:, order_permission_request_token:, order_permission_onboarding_id:)
      query_one(person_id: person_id, community_id: community_id, order_permission_request_token: order_permission_request_token, order_permission_onboarding_id: order_permission_onboarding_id)
    end

    def find_active(person_id: nil, community_id:)
      query_one(person_id: person_id, community_id: community_id, active: true)
    end

    def find_all(person_id: nil, community_id:)
      query_all(person_id: person_id, community_id: community_id)
    end

    def find_active_users(community_id:)
      query_all(community_id: community_id, active: true)
    end

    private

    def query_all(params)
      query = construct_query(params)

      Maybe(
        PaypalAccountModel.where(query)
        .eager_load([:order_permission, :billing_agreement])
      )
    end

    def query_one(params)
      query_all(params).map(&:first)
    end

    # Takes a hash and rejects values :all
    def construct_query(params)
      account_params = FlattingHelper.select_paypal_account_values(params)
      order_permission_params = HashUtils.wrap_if_present(
        :order_permissions,
        FlattingHelper.select_order_permission_values(params)
      )

      account_params.merge(order_permission_params)
    end
  end

  module_function

  ## Public Store CRUD methods:

  def create(opts:)
    entity = PaypalAccountCreate.call(opts)
    account = HashUtils.compact(FlattingHelper.select_paypal_account_values(entity))
    order_permission = HashUtils.compact(FlattingHelper.select_order_permission_values(entity))

    account_model = PaypalAccountModel.create!(account)
    account_model.create_order_permission(order_permission)
    account_model = update_or_create_billing_agreement(account_model, HashUtils.compact(FlattingHelper.select_billing_agreement_values(entity)))


    from_model(Maybe(account_model))
  end

  def update(community_id:, person_id: nil, payer_id:, opts:)
    find_params = {
      community_id: community_id,
      person_id: person_id,
      payer_id: payer_id
    }

    model = finder.find(find_params)
    update_model(model, opts, find_params)
  end

  def update_pending(community_id:, person_id: nil, order_permission_request_token:, order_permission_onboarding_id:, opts:)
    find_params = {
      community_id: community_id,
      person_id: person_id,
      order_permission_request_token: order_permission_request_token,
      order_permission_onboarding_id: order_permission_onboarding_id
    }

    model = finder.find_pending(find_params)
    update_model(model, opts, find_params)
  end

  def update_active(community_id:, person_id: nil, opts:)
    find_params = {
      community_id: community_id,
      person_id: person_id
    }

    model = finder.find_active(find_params)
    update_model(model, opts, find_params)
  end

  def delete_billing_agreement(person_id:, community_id:)
    maybe_account = finder.find_active(person_id: person_id, community_id: community_id)
    maybe_account.billing_agreement.each { |billing_agreement| billing_agreement.destroy }
  end

  def delete_billing_agreement_by_payer_and_agreement_id(payer_id:, billing_agreement_id:)
    maybe_billing_agreement = find_billing_agreement_by_payer_and_agreement_id(payer_id: payer_id, billing_agreement_id: billing_agreement_id)
    maybe_billing_agreement.each { |billing_agreement| billing_agreement.destroy }
  end

  def delete_pending(person_id: nil, community_id:, order_permission_request_token:, order_permission_onboarding_id:)
    model = finder.find_pending(
      community_id: community_id,
      person_id: person_id,
      order_permission_request_token: order_permission_request_token,
      order_permission_onboarding_id: order_permission_onboarding_id
    )
    model.each { |account| account.destroy }
  end

  def delete_all(person_id: nil, community_id:)
    finder.find_all(person_id: person_id, community_id: community_id).each { |accounts|
      accounts.each { |account| account.destroy }
    }
  end

  def get(person_id: nil, community_id:, payer_id:)
    from_model(
      finder.find(
        person_id: person_id,
        community_id: community_id,
        payer_id: payer_id
      )
    )
  end

  def get_active(person_id: nil, community_id:)
    from_model(
      finder.find_active(
        person_id: person_id,
        community_id: community_id
      )
    )
  end

  def get_active_users(community_id:)
    finder.find_active_users(community_id: community_id).get
      .where.not(person_id: nil)
      .map(&:person_id)
  end

  ## Privates

  def update_model(maybe_model, opts, find_params)
    entity = PaypalAccountUpdate.call(opts)

    case maybe_model
    when Some
      account_model = maybe_model.get
      account_values = HashUtils.compact(FlattingHelper.select_paypal_account_values(entity))

      account_model.update_attributes(account_values)
      account_model.order_permission.update_attributes(HashUtils.compact(FlattingHelper.select_order_permission_values(entity)))
      account_model = update_or_create_billing_agreement(account_model, HashUtils.compact(FlattingHelper.select_billing_agreement_values(entity)))

      deactivate_other_accounts(account_model) if account_values[:active]

      from_model(Maybe(account_model))
    else
      msg = "Cannot find Paypal account #{find_params}"

      raise ArgumentError.new(msg) unless account_model
    end
  end

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

  def deactivate_other_accounts(active_account_model)
    base_query =
      PaypalAccountModel.where(
        "community_id = ? AND id != ?",
        active_account_model.community_id,
        active_account_model.id
      )

    query =
      if active_account_model.person_id.nil?
        # community account
        base_query.where("person_id IS NULL")
      else
        # personal account
        base_query.where("person_id = ?", active_account_model.person_id)
      end

    query.update_all(active: false)
  end

  def find_billing_agreement_by_payer_and_agreement_id(payer_id:, billing_agreement_id:)
    Maybe(
      BillingAgreement
      .joins(:paypal_account)
      .where(
        {
          billing_agreement_id: billing_agreement_id,
          paypal_accounts: {payer_id: payer_id}
        })
      .readonly(false)
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
          if perm.verification_code || perm.permissions_granted
            :verified
          elsif perm.request_token || perm.onboarding_id
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
    when matches([__, :verified, __])
      # billing agreement might be pending or not set
      :connected
    else
      :not_connected
    end
  end

  def finder
    @finder ||= PaypalAccountFinder.new
  end
end
