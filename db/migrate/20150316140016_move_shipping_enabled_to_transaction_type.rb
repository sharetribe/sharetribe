class MoveShippingEnabledToTransactionType < ActiveRecord::Migration
  def up
    execute("
      UPDATE transaction_types

      INNER JOIN marketplace_settings ON transaction_types.community_id = marketplace_settings.community_id AND transaction_types.preauthorize_payment = 1

      SET transaction_types.shipping_enabled = marketplace_settings.shipping_enabled
    ")
  end

  def down
    execute("UPDATE transaction_types SET shipping_enabled = 0")
  end
end
