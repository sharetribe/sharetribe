class AlterMessagesAddIndexOnSender < ActiveRecord::Migration[5.2]
  def change
    # At present, this index is useful for data/user deletion, but not utilized
    # elsewhere.
    add_index :messages, :sender_id
  end
end
