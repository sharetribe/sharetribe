class AddSumCentsAndCurrencyToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :sum_cents, :integer
    add_column :payments, :currency, :string
  end
end
