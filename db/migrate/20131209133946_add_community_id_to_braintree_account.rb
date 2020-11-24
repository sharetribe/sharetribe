class AddCommunityIdToBraintreeAccount < ActiveRecord::Migration
  def change
    add_column :braintree_accounts, :community_id, :int
  end
end
