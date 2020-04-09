class AddEmailAdminsAboutNewMembersToCommunities < ActiveRecord::Migration[5.2]
def self.up
    add_column :communities, :email_admins_about_new_members, :boolean, :default => 0
  end

  def self.down
    remove_column :communities, :email_admins_about_new_members
  end
end
