class CreatePaypalTokensTable < ActiveRecord::Migration
  def change
    create_table :paypal_tokens do |t|
      # I'm not exactly sure how long the token is, but 64 should be enough
      t.column :token, :string, limit: 64
      t.column :transaction_id, :integer
      t.column :created_at, :datetime
      # Rows do not get updated, so no need for `updated_at` column
    end

    add_index :paypal_tokens, :token, unique: true
    # We do not do searches based on `transaction_id` so no need to add index for that
  end
end
