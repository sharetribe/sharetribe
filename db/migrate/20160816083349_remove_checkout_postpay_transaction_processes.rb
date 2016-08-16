class RemoveCheckoutPostpayTransactionProcesses < ActiveRecord::Migration
  def up
    execute("
      DELETE transaction_processes FROM transaction_processes
      LEFT JOIN payment_gateways pg ON (pg.community_id = transaction_processes.community_id)
      WHERE pg.type = 'Checkout' AND transaction_processes.process = 'postpay'
    ")
  end
end
