class AddMemberLimitToMarketplacePlans < ActiveRecord::Migration
  def change
    add_column :marketplace_plans, :member_limit, :integer, default: nil, null: true, after: :features
  end
end
