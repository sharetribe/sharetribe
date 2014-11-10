module PaypalService
  module PaypalAccount
    PaypalAccountModel = ::PaypalAccount

    module Entity
      PaypalAccount = EntityUtils.define_entity(
        :email,
        :payer_id,
        :person_id,
        :community_id,
        :order_permission_state, # one of :not_requested, :pending, :verified
        :request_token, # order permission request token
        :billing_agreement_id,
        :billing_agreement_request_token,
        :billing_agreement_state, # one of :not_requested, :pending, :verified
      )

      module_function

      def paypal_account(paypal_acc_model)
        hash = EntityUtils.model_to_hash(paypal_acc_model)
          .merge(order_permission_to_hash(paypal_acc_model.order_permission))
          .merge(HashUtils.rename_keys(
            {request_token: :billing_agreement_request_token},
            billing_agreement_to_hash(paypal_acc_model.billing_agreement)))
        PaypalAccount.call(hash)
      end


      def order_permission_to_hash(order_perm_model)
        if (order_perm_model.nil?)
          { order_permission_state: :not_requested }
        elsif (order_perm_model.verification_code.nil?)
          { order_permission_state: :pending }
        else
          { order_permission_state: :verified }
        end
          .merge(EntityUtils.model_to_hash(order_perm_model))
      end

      def order_permission_verified?(paypal_account)
        return (paypal_account && paypal_account[:order_permission_state] == :verified)
      end

      def paypal_account_prepared?(paypal_account)
        return (paypal_account &&
          paypal_account[:order_permission_state] == :verified &&
          paypal_account[:billing_agreement_state] == :verified)
      end

      def billing_agreement_to_hash(billing_agreement_model)
        if (billing_agreement_model.nil?)
          { billing_agreement_state: :not_requested }
        elsif (billing_agreement_model.billing_agreement_id.nil?)
          { billing_agreement_state: :pending }
        else
          { billing_agreement_state: :verified }
        end
          .merge(EntityUtils.model_to_hash(billing_agreement_model))
      end
    end

    module Command

      module_function

      def create_personal_account(person_id, community_id, account_data = {})
        old_account = PaypalAccountModel
          .where(person_id: person_id, community_id: community_id)
          .eager_load(:order_permission)
          .first

        old_account.destroy if old_account.present?

        PaypalAccountModel.create!(
          account_data.merge({person_id: person_id, community_id: community_id})
        )
        Result::Success.new
      end

      def update_personal_account(person_id, community_id, account_data)
        paypal_account = PaypalAccountModel
          .where(person_id: person_id, community_id: community_id)
          .eager_load(:order_permission)
          .first

        paypal_account.update_attributes(account_data)
        Result::Success.new
      end

      def destroy_personal_account(person_id, community_id)
        Maybe(PaypalAccountModel.where(person_id: person_id, community_id: community_id))
          .map { |paypal_account|
            paypal_account.destroy ? true : false;
          }
      end

      def create_admin_account(community_id, account_data = {})
        old_account = PaypalAccountModel
          .where(person_id: nil, community_id: community_id)
          .eager_load(:order_permission)
          .first

        old_account.destroy if old_account.present?

        PaypalAccountModel.create!(
          account_data.merge({community_id: community_id, person_id: nil})
        )

        Result::Success.new
      end

      def update_admin_account(community_id, account_data)
        paypal_account = PaypalAccountModel
          .where(person_id: nil, community_id: community_id)
          .eager_load(:order_permission)
          .first

        paypal_account.update_attributes(account_data)
        Result::Success.new
      end

      def create_pending_permissions_request(person_id, community_id, paypal_username_to, permissions_scope, request_token)
        Maybe(PaypalAccountModel
            .where(person_id: person_id, community_id: community_id)
            .eager_load(:order_permission)
            .first
          )
          .map { |paypal_account|

            Maybe(paypal_account.order_permission).destroy

            OrderPermission.create!(
              {
                paypal_account: paypal_account,
                request_token: request_token,
                paypal_username_to: paypal_username_to
              }
            )
            true
          }
          .or_else(false)
      end

      def confirm_pending_permissions_request(person_id, community_id, request_token, scope, verification_code)
        # Should this fail silently in case of no matching permission request?
        order_permission =  OrderPermission
          .eager_load(:paypal_account)
          .where({
            :request_token => request_token,
            "paypal_accounts.person_id" => person_id,
            "paypal_accounts.community_id" => community_id
          })
          .first
        if order_permission.present?
            order_permission[:scope] = scope
            order_permission[:verification_code] = verification_code
            order_permission.save!
            true
        else
          false
        end
      end

      def create_pending_billing_agreement(person_id, community_id, paypal_username_to, request_token)
        # Create new pending billing agreement and save it for the paypal account connected to user and community
        # Ensure that this is the only billing agreement for the pp account by deleting any previous requests(?)
        Maybe(PaypalAccountModel
            .where(person_id: person_id, community_id: community_id)
            .eager_load(:billing_agreement)
            .first
          )
          .map { |paypal_account|
            Maybe(paypal_account.billing_agreement).destroy

            BillingAgreement.create!(
              {
                paypal_account: paypal_account,
                request_token: request_token,
                paypal_username_to: paypal_username_to
              }
            )
            true
          }
          .or_else(false)
      end

      def cancel_pending_billing_agreement(person_id, community_id, request_token)
        # Delete billing agreement as a result of user clicking cancel at paypal site
        Maybe(BillingAgreement
            .eager_load(:paypal_account)
            .where({
              :request_token => request_token,
              "paypal_accounts.person_id" => person_id,
              "paypal_accounts.community_id" => community_id
            })
            .first
          )
          .map {|billing_agreement|
          billing_agreement.destroy
          true
        }
          .or_else(false)
      end

      def delete_cancelled_billing_agreement(payer_id, billing_agreement_id)
        billing_agreement = Maybe(BillingAgreement
          .eager_load(:paypal_account)
          .where({
            "paypal_accounts.payer_id"  => payer_id,
            :billing_agreement_id  => billing_agreement_id
          }).first)

       billing_agreement.each {|ba| ba.destroy }

       billing_agreement.is_some?
      end

      def confirm_billing_agreement(person_id, community_id, request_token, billing_agreement_id)
        # Should this fail silently in case of no matching billing agreement?
        Maybe(BillingAgreement
            .eager_load(:paypal_account)
            .where({
              :request_token => request_token,
              "paypal_accounts.person_id" => person_id,
              "paypal_accounts.community_id" => community_id
            })
            .first
          )
          .map {|billing_agreement|
            billing_agreement[:billing_agreement_id] = billing_agreement_id
            billing_agreement.save!
            true
          }
          .or_else(false)
      end
    end

    module Query

      module_function

      def personal_account(person_id, community_id)
        Maybe(PaypalAccountModel
            .where(person_id: person_id, community_id: community_id)
            .eager_load([:order_permission, :billing_agreement])
            .first)
          .map { |model| Entity.paypal_account(model) }
          .or_else(nil)
      end

      def admin_account(community_id)
        Maybe(PaypalAccountModel.where(community_id: community_id, person_id: nil)
            .eager_load([:order_permission, :billing_agreement])
            .first)
          .map { |model| Entity.paypal_account(model) }
          .or_else(nil)
      end

      def for_payer_id(community_id, payer_id)
        Maybe(PaypalAccountModel.where("community_id = ? AND payer_id = ? AND person_id IS NOT NULL", community_id, payer_id)
            .eager_load([:order_permission, :billing_agreement])
            .first)
        .map { |model| Entity.paypal_account(model) }
        .or_else(nil)
      end
    end
  end

end
