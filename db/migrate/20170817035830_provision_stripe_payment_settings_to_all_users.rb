class ProvisionStripePaymentSettingsToAllUsers < ActiveRecord::Migration[5.1]
  def up
    communities_with_stripe_ids    = connection.select_values("SELECT community_id FROM payment_settings WHERE payment_gateway = 'stripe'")

    communities_without_paypal_query = <<-SQL
    SELECT c.id
    FROM communities c
    LEFT OUTER JOIN payment_settings ps ON ps.community_id = c.id AND ps.payment_gateway = 'paypal'
    WHERE ps.id IS NULL
    SQL
    communities_without_paypal_ids = connection.select_values communities_without_paypal_query

    excluded_ids = communities_without_paypal_ids + communities_with_stripe_ids
    if excluded_ids.present?
      excluded_where = "AND community_id NOT IN (#{excluded_ids.join(",")})"
    else
      excluded_where = ""
    end

    provision_query = <<-SQL
    INSERT INTO payment_settings (community_id, active, payment_gateway, payment_process, commission_from_seller,
      minimum_price_cents, minimum_price_currency, minimum_transaction_fee_cents,
      minimum_transaction_fee_currency, confirmation_after_days, created_at, updated_at)
    SELECT community_id, active, 'stripe', payment_process, commission_from_seller,
      minimum_price_cents, minimum_price_currency, minimum_transaction_fee_cents,
      minimum_transaction_fee_currency, confirmation_after_days, NOW(), NOW()
    FROM payment_settings
    WHERE payment_gateway = 'paypal' AND payment_process = 'preauthorize' #{excluded_where}
    SQL

    connection.execute provision_query
  end
end
