class RemovePreauthorizePaymentFromTransactionTypes < ActiveRecord::Migration
  def up
    remove_column :transaction_types, :preauthorize_payment
  end

  def down
    add_column :transaction_types, :preauthorize_payment, :boolean, after: :price_field

    execute("
      UPDATE transaction_types, transaction_processes SET transaction_types.preauthorize_payment = (transaction_processes.process = 'preauthorize')
      WHERE transaction_types.transaction_process_id = transaction_processes.id
    ")
  end
end
