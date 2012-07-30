extends "api/conversations/no_messages"
node :last_message do |c|
  {:content => c.messages.last.content, :sender_id => c.messages.last.sender_id, :created_at => c.messages.last.created_at}
end
