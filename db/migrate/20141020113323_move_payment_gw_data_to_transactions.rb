class MovePaymentGwDataToTransactions < ActiveRecord::Migration
  def up
    execute(<<-EOQ)
       UPDATE transactions t
       LEFT JOIN payment_gateways pgw ON (t.community_id = pgw.community_id)
       LEFT JOIN paypal_payments pp ON (t.id = pp.transaction_id)
       SET t.payment_gateway = CASE
                                    WHEN t.current_state = "free" THEN "none"
                                    WHEN pp.id IS NOT NULL THEN "paypal"
                                    WHEN pgw.type = "Checkout" THEN "checkout"
                                    WHEN pgw.type = "BraintreePaymentGateway" THEN "braintree"
                                    ELSE "none"
                               END
    EOQ
  end

  def down
    execute(<<-EOQ)
      UPDATE transactions t
      SET t.payment_gateway = "none"
    EOQ
  end
end
