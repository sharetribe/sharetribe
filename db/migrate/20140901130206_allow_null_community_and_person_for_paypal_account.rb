class AllowNullCommunityAndPersonForPaypalAccount < ActiveRecord::Migration
  def change
    change_column :paypal_accounts, :person_id, :int, :null => true
    change_column :paypal_accounts, :community_id, :int, :null => true
  end
end
