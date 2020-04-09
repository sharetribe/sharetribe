class AddCommunityIdToPaypalPayment < ActiveRecord::Migration[5.2]
def change
    add_column :paypal_payments, :community_id, :integer, null: false, after: :id
  end
end
