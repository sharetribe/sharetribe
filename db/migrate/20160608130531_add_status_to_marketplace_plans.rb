class AddStatusToMarketplacePlans < ActiveRecord::Migration
  def change
    add_column :marketplace_plans, :status, :string, limit: 22, after: :plan_level
  end
end
