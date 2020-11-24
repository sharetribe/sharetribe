class AddAllowFreeConversationsFlagToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :allow_free_conversations, :boolean, default: true
  end
end
