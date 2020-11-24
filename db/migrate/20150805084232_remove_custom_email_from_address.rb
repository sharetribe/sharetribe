class RemoveCustomEmailFromAddress < ActiveRecord::Migration
  def up
    remove_column :communities, :custom_email_from_address
  end

  def down
    add_column :communities, :custom_email_from_address, :string, after: :only_public_listings
  end
end
