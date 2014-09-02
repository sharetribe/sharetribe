class AddPaypalEnabledToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :paypal_enabled, :boolean, null: false, default: false
  end
end
