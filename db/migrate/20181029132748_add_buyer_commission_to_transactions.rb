class AddBuyerCommissionToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :commission_from_buyer, :integer
    add_column :transactions, :minimum_buyer_fee_cents, :integer, default: 0
    add_column :transactions, :minimum_buyer_fee_currency, :string, limit: 3
  end
end
