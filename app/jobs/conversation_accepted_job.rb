class ConversationAcceptedJob < Struct.new(:conversation_id, :host) 
  
  def perform
    conversation = Conversation.find(conversation_id)
    if conversation.listing.share_types.collect(&:name).eql?(["give_away"]) && Time.now.month == 12
      conversation.offerer.give_badge("santa", host)
    end
    Delayed::Job.enqueue(TestimonialReminderJob.new(conversation.id, host), 0, 1.week.from_now)
  end
  
end