class CreateUnitsTable < ActiveRecord::Migration
  def change
    create_table :listing_units do |t|
      t.string :unit_type, limit: 32, null: false
      t.string :translation_key, limit: 64
      t.integer :transaction_type_id

      t.timestamps null: false
    end
  end
end
