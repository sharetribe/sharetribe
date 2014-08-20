class CreatePaypalAccounts < ActiveRecord::Migration
  def change
    create_table :paypal_accounts do |t|
      t.string :person_id
      t.integer :community_id
      t.string :username
      t.string :api_key
      t.string :signature

      t.timestamps
    end
  end
end
