class ChangePaymentColumnToInteger < ActiveRecord::Migration[5.2]
def self.up
    change_column :favors, :payment, :integer
  end

  def self.down
    change_column :favors, :payment, :string
  end
end
