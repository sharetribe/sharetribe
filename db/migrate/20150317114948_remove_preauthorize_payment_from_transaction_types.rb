class RemovePreauthorizePaymentFromTransactionTypes < ActiveRecord::Migration
  def up
    remove_column :transaction_types, :preauthorize_payment
  end

  def down
    add_column :transaction_types, :preauthorize_payment, :boolean, after: :price_field
  end
end
