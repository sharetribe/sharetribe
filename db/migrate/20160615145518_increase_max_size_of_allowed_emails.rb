class IncreaseMaxSizeOfAllowedEmails < ActiveRecord::Migration
  def change
    change_column :communities, :allowed_emails, :text, limit: 16.megabytes - 1
  end
end
