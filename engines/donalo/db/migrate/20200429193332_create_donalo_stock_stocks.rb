class CreateDonaloStockStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :donalo_stock_stocks do |t|
      t.references :listing, foreign_key: true, type: :integer
      t.integer :amount, default: 0

      t.timestamps
    end
  end
end
