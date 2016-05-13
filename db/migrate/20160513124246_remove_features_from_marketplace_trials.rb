class RemoveFeaturesFromMarketplaceTrials < ActiveRecord::Migration
  def change
    remove_column :marketplace_trials, :features, :text, after: :community_id
  end
end
