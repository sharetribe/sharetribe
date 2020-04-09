class AddHideExpirationDateToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :hide_expiration_date, :boolean, :default => false
  end
end
