class PopulatePaymentProcess < ActiveRecord::Migration
  def up
    execute("
      UPDATE transactions, listings, transaction_types, payment_gateways, communities

      SET transactions.payment_process =
      CASE
      WHEN (communities.paypal_enabled = 1 OR payment_gateways.id IS NOT NULL) THEN
        CASE
        WHEN transaction_types.price_field = 0 THEN
          'none'
        WHEN transaction_types.preauthorize_payment THEN
          'preauthorize'
        ELSE
          'postpay'
        end
      ELSE
        'none'
      END

      WHERE transaction_types.id = listings.transaction_type_id
        AND listings.id = transactions.listing_id
        AND communities.id = transactions.community_id
        AND communities.id = payment_gateways.community_id
    ")
  end

  def down
    execute("UPDATE transactions SET payment_process = 'none'")
  end
end
