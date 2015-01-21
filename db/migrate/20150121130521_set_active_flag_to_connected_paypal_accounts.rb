class SetActiveFlagToConnectedPaypalAccounts < ActiveRecord::Migration
  def up
    execute("UPDATE paypal_accounts
             LEFT JOIN billing_agreements ON (paypal_accounts.id = billing_agreements.paypal_account_id)
             LEFT JOIN order_permissions ON (paypal_accounts.id = order_permissions.paypal_account_id)

             SET paypal_accounts.active =
               (
                 (
                   billing_agreements.billing_agreement_id IS NOT NULL
                   AND order_permissions.verification_code IS NOT NULL
                   AND paypal_accounts.person_id IS NOT NULL
                 )
                 OR
                 (
                   order_permissions.verification_code IS NOT NULL
                   AND paypal_accounts.person_id IS NULL
                 )
               )
            ")
  end

  def down
    execute("UPDATE paypal_accounts SET active = 0")
  end
end
