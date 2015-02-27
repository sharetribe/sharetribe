class AddIdentToMarketplace < ActiveRecord::Migration
  def change
    add_column :communities, :ident, :string, after: :id
    add_index :communities, :ident
  end
end
