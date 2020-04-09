class AddEmailToInvitations < ActiveRecord::Migration[5.2]
def self.up
    add_column :invitations, :email, :string
  end

  def self.down
    remove_column :invitations, :email
  end
end
