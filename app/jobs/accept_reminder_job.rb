class AcceptReminderJob < Struct.new(:conversation_id, :last_message_id, :host)
  
  def perform
    conversation = Conversation.find(conversation_id)
    if conversation.status.eql?("pending")
      if conversation.messages.last.created_at < 1.week.ago
        recipient = conversation.other_party(Message.find(last_message_id).sender)
        if recipient.should_receive?("email_about_accept_reminders")
          PersonMailer.accept_reminder(conversation, recipient, host).deliver
        end
      end
      Delayed::Job.enqueue(AcceptReminderJob.new(conversation.id, host), 0, 1.weeks.from_now)
    end
  end
  
end