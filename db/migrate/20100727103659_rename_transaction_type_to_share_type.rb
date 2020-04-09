class RenameTransactionTypeToShareType < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :listings, :transaction_type, :share_type
  end

  def self.down
    rename_column :listings, :share_type, :transaction_type
  end
end
