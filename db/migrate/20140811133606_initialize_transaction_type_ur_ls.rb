class InitializeTransactionTypeUrLs < ActiveRecord::Migration
  def up
    TransactionType.reset_column_information
    TransactionType.initialize_urls
  end

  def down
  end
end
