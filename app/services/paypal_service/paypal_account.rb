module PaypalService
  module PaypalAccount
    module Command
      module_function

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
    end
  end
end
