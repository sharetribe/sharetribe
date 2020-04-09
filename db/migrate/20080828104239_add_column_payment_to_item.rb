class AddColumnPaymentToItem < ActiveRecord::Migration[5.2]
def self.up
      add_column :items, :payment, :integer
  end

  def self.down
      remove_column :items, :payment
  end
end
