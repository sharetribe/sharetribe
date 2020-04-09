class AddPaymentProcessToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payment_process, :string, limit: 31, default: "none"
  end
end
