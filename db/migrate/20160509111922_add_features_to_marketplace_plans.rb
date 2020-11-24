class AddFeaturesToMarketplacePlans < ActiveRecord::Migration
  def change
    add_column :marketplace_plans, :features, :text, after: :plan_level
  end
end
