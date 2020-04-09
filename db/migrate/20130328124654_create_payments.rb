class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :payer_id
      t.string :recipient_id
      t.string :organization_id
      t.integer :conversation_id
      t.integer :sum_cents
      t.string :sum_currency
      t.string :status

      t.timestamps
    end
  end
end
