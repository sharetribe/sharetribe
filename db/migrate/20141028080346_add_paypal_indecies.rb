class AddPaypalIndecies < ActiveRecord::Migration
  def change
    add_index :paypal_tokens, :community_id
    add_index :paypal_tokens, :transaction_id
  end
end
