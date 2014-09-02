class CreatePaypalAccounts < ActiveRecord::Migration
  def change
    create_table :paypal_accounts do |t|
      t.string :person_id, null: false
      t.integer :community_id, null: false
      t.string :username, null: false
      t.string :api_password, null: true
      t.string :api_signature, null: true

      t.timestamps
    end

    create_table :order_permissions do |t |
      t.integer :from_account_id, null: false
      t.integer :to_account_id, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    create_table :billing_agreements do |t |
      t.integer :from_account_id, null: false
      t.integer :to_account_id, null: false
      t.string :status, null: false, default: "pending"
      t.string :billing_agreement_id, null: true

      t.timestamps
    end
  end
end
