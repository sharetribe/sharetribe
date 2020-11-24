class AddMinimumCommissionToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :minimum_commission_cents, :integer, default: 0, after: :commission_from_seller
    add_column :transactions, :minimum_commission_currency, :string, after: :minimum_commission_cents
  end
end
