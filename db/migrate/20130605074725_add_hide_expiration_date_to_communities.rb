class AddHideExpirationDateToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :hide_expiration_date, :boolean, :default => false
  end
end
