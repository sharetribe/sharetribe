class PopulatePaypalTokenReceiverIds < ActiveRecord::Migration[5.2]
def up
    execute("
      UPDATE paypal_tokens
      LEFT JOIN paypal_accounts ON (paypal_accounts.person_id = paypal_tokens.merchant_id)

      SET paypal_tokens.receiver_id = paypal_accounts.payer_id
    ")
  end

  def down
    #noop
  end
end
