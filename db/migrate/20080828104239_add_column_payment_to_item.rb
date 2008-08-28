class AddColumnPaymentToItem < ActiveRecord::Migration
  def self.up
      add_column :items, :payment, :integer
  end

  def self.down
      remove_column :items, :payement
  end
end
