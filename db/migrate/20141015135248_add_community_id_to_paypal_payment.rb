class AddCommunityIdToPaypalPayment < ActiveRecord::Migration
  def change
    add_column :paypal_payments, :community_id, :integer, null: false, after: :id
  end
end
