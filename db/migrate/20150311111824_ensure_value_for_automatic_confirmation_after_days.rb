class EnsureValueForAutomaticConfirmationAfterDays < ActiveRecord::Migration[5.2]
  def up
    execute("
      UPDATE transactions
      SET automatic_confirmation_after_days =
        CASE payment_gateway
	  WHEN 'paypal' THEN 14
	  WHEN 'braintree' THEN 14
	  WHEN 'checkout' THEN 14
	  ELSE 0
       END
       WHERE automatic_confirmation_after_days IS NULL")
  end

  def down
  end
end
