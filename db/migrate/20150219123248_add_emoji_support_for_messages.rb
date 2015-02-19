class AddEmojiSupportForMessages < ActiveRecord::Migration
  def up
    execute "ALTER TABLE messages charset=utf8mb4, MODIFY COLUMN content TEXT CHARACTER SET utf8mb4"
  end

  def down
    #no-op
  end
end
