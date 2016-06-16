class IncreaseMaxSizeOfAllowedEmails < ActiveRecord::Migration
  def up
    change_column :communities, :allowed_emails, :text, limit: 16.megabytes - 1
  end
  def down
    change_column :communities, :allowed_emails, :text
  end
end
