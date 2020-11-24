class ChangePaymentColumnToInteger < ActiveRecord::Migration
  def self.up
    change_column :favors, :payment, :integer
  end

  def self.down
    change_column :favors, :payment, :string
  end
end
