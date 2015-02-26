class AddUsernameToMarketplace < ActiveRecord::Migration
  def change
    add_column :communities, :username, :string, after: :id, null: false
    add_index :communities, :username
  end
end
