object @conversation
attributes :id, :title, :status, :listing_id, :created_at, :updated_at
child :messages do
  attributes :content, :sender_id, :created_at
end
child :participations do
  attributes :person_id, :is_read, :last_sent_at, :last_received_at, :feedback_skipped
end
