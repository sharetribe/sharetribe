class AddPreauthorizePaymentToTransactionTypes < ActiveRecord::Migration
  def change
    add_column :transaction_types, :preauthorize_payment, :boolean, after: :price_field, default: false
  end
end
