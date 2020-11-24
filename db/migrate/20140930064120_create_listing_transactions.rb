class CreateListingTransactions < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.string :starter_id, null: false
      t.integer :listing_id, null: false
      t.integer :conversation_id, null: true
      t.integer :automatic_confirmation_after_days, null: true
      t.integer :community_id, null: false

      t.timestamps
    end
  end

  def down
    drop_table :transactions
  end
end
