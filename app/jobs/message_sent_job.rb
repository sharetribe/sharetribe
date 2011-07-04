class MessageSentJob < Struct.new(:conversation_id, :last_message_id, :host)
  
  def perform
    conversation = Conversation.find(conversation_id)
    conversation.send_email_to_participants(host)
    Delayed::Job.enqueue(AcceptReminderJob.new(conversation.id, last_message_id, host), 0, 1.week.from_now)
  end
  
end