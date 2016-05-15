class AddFeaturesToMarketplaceTrials < ActiveRecord::Migration
  def change
    add_column :marketplace_trials, :features, :text, after: :community_id
  end
end
