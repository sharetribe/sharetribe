class CreateMarketplaceTrialsTable < ActiveRecord::Migration

  def change
    create_table :marketplace_trials do |t|
      t.integer  :community_id,              :null => false
      t.datetime :expires_at
      t.datetime :created_at,                  :null => false
      t.datetime :updated_at,                  :null => false
    end
  end

end
