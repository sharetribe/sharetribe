class RemoveMemberLimitFromMarketplaceTrials < ActiveRecord::Migration
  def change
    remove_column :marketplace_trials, :member_limit, :integer, default: nil, null: true, after: :features
  end
end
