class RemoveCoinAmountFromPerson < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :people, :coin_amount
  end

  def self.down
    add_column :people, :coin_amount, :integer
  end
end
