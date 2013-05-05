object @conversation
attributes :id, :title, :status, :listing_id, :last_message_at, :created_at, :updated_at

child :participations do
  attributes :is_read, :last_sent_at, :last_received_at, :feedback_skipped
  child :person do 
    extends "api/people/small_info"
  end
end
