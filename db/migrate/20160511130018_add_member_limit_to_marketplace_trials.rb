class AddMemberLimitToMarketplaceTrials < ActiveRecord::Migration
  def change
    add_column :marketplace_trials, :member_limit, :integer, default: nil, null: true, after: :features
  end
end
