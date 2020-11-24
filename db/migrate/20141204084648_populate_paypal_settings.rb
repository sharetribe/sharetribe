class PopulatePaypalSettings < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO payment_settings (active, community_id, payment_gateway, payment_process, commission_from_seller, minimum_price_cents, confirmation_after_days, created_at, updated_at)
      SELECT true, c.id, 'paypal', 'preauthorize', c.commission_from_seller, c.minimum_price_cents, c.automatic_confirmation_after_days, NOW(), NOW()
      FROM communities c WHERE c.paypal_enabled = TRUE;
    ")
  end

  def down
    execute("
      DELETE FROM payment_settings
      WHERE payment_gateway = 'paypal';
    ")
  end
end
