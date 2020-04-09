class RemoveSumFromPayments < ActiveRecord::Migration[5.2]
def up
    remove_column :payments, :sum_cents 
    remove_column :payments, :currency
  end

  def down
    add_column :payments, :sum_cents, :integer, :default => nil
    add_column :payments, :currency, :string, :default => nil
  end
end
