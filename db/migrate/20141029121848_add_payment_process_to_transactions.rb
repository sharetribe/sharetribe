class AddPaymentProcessToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :payment_process, :string, limit: 31
  end
end
