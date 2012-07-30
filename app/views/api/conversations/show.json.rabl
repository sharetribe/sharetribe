object @conversation
extends "api/conversations/no_messages"

child :messages do
  attributes :content, :sender_id, :created_at
end

