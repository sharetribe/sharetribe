class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.string :sender_id
      t.string :receiver_id
      t.integer :listing_id
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
