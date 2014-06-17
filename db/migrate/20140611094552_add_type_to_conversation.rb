class AddTypeToConversation < ActiveRecord::Migration
  def change
    add_column :conversations, :type, :string, :default => 'Conversation', :after => :id
  end
end
