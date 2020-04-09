class AddPaypalEnabledToCommunity < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :paypal_enabled, :boolean, null: false, default: false
  end
end
