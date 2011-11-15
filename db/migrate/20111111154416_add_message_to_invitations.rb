class AddMessageToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :message, :text
  end

  def self.down
    remove_column :invitations, :message
  end
end
