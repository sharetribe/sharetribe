class RemovePaypalEnabled < ActiveRecord::Migration
  def up
    remove_column :communities, :paypal_enabled
  end

  def down
    add_column :communities, :paypal_enabled, :boolean, default: false, null: false
  end
end
