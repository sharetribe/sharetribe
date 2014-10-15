class AddCommunityIdToPaypalToken < ActiveRecord::Migration
  def change
    add_column :paypal_tokens, :community_id, :integer, null: false, after: :id
  end
end
