class ChangePostpayTransactionProcessToFree < ActiveRecord::Migration[5.2]
  def up
    execute "UPDATE transaction_processes SET process = 'none' WHERE process = 'postpay'"
  end

  def down
    execute "UPDATE transaction_processes SET process = old_process WHERE old_process = 'postpay'"
  end
end
