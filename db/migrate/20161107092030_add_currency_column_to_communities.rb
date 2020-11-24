class AddCurrencyColumnToCommunities < ActiveRecord::Migration
  def up
    add_column :communities, :currency, :string, limit: 3, after: :available_currencies
  end

  def down
    remove_column :communities, :currency
  end
end
