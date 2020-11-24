class AddCustomEmailFromAddressToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :custom_email_from_address, :string
  end
end
