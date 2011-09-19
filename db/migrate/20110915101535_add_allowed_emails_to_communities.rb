class AddAllowedEmailsToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :email_confirmation, :boolean, :default => false
    add_column :communities, :allowed_emails, :text
  end

  def self.down
    remove_column :communities, :email_confirmation
    remove_column :communities, :allowed_emails
  end
end
