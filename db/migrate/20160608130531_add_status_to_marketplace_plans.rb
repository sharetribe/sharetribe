class AddStatusToMarketplacePlans < ActiveRecord::Migration[5.2]
def change
    add_column :marketplace_plans, :status, :string, limit: 22, after: :plan_level
  end
end
