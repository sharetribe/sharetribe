class ConversationAcceptedJob < Struct.new(:conversation_id, :current_user_id, :community_id, :host) 
  
  def perform
    conversation = Conversation.find(conversation_id)
    current_user = Person.find(current_user_id)
    if conversation.other_party(current_user).should_receive?("email_when_conversation_#{conversation.status}")
      PersonMailer.conversation_status_changed(conversation, host).deliver
    end
    if conversation.status.eql?("accepted")
      EventFeedEvent.create(:person1_id => conversation.offerer.id, :person2_id => conversation.requester.id, :community_id => community_id, :category => "accept", :members_only => !conversation.listing.visibility.eql?("everybody"))
      if conversation.listing.share_type.eql?(["give_away"]) && Time.now.month == 12
        conversation.offerer.give_badge("santa", host)
      end
      Delayed::Job.enqueue(TestimonialReminderJob.new(conversation.id, host), :priority => 0, :run_at => 1.week.from_now)
    end
  end
  
end