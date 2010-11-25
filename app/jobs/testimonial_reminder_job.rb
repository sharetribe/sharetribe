class TestimonialReminderJob < Struct.new(:conversation_id, :host) 
  
  def perform
    conversation = Conversation.find(conversation_id)
    if conversation.status.eql?("accepted") && !conversation.has_feedback_from_all_participants?
      conversation.participants.each do |participant|
        participation = Participation.find_by_person_id_and_conversation_id(participant.id, conversation.id)
        participation.send_testimonial_reminder(host)
      end
      Delayed::Job.enqueue(TestimonialReminderJob.new(conversation.id, host), 0, 1.month.from_now)
    end
  end
  
end