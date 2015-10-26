class CreateMarketplacePlansTable < ActiveRecord::Migration

  def change
    create_table :marketplace_plans do |t|
      t.integer  :community_id,                :null => false
      t.integer  :plan_level
      t.datetime :expires_at
      t.datetime :created_at,                  :null => false
      t.datetime :updated_at,                  :null => false
    end
  end

end
