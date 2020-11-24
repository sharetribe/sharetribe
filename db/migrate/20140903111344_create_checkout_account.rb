class CreateCheckoutAccount < ActiveRecord::Migration
  def change
    create_table :checkout_accounts do |t|
      t.string :company_id, null: true
      t.string :merchant_id, null: false
      t.string :merchant_key, null: false
      t.string :person_id, null: false

      t.timestamps
    end
  end
end
