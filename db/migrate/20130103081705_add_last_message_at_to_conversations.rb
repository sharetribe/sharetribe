class AddLastMessageAtToConversations < ActiveRecord::Migration
  def up
    add_column :conversations, :last_message_at, :datetime
    Conversation.all.each do |c|
      # Participations have the same dates so just look at first one
      p = c.participations.first
      if p.present?
        if (p.last_sent_at && p.last_received_at.nil?) || (p.last_sent_at && p.last_sent_at > p.last_received_at)
          c.update_column(:last_message_at, p.last_sent_at)
        else
          c.update_column(:last_message_at, p.last_received_at)
        end
      end
    end
  end
  
  def down
    remove_column :conversations, :last_message_at
  end
end
