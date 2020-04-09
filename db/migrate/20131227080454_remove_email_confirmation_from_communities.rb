class RemoveEmailConfirmationFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :email_confirmation
  end

  def down
    add_column :communities, :email_confirmation, :boolean
  end
end
