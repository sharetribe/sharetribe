class ConversationAcceptedJob < Struct.new(:conversation_id, :current_user_id, :community_id, :host) 
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_host(host)
  end
  
  def perform
    conversation = Conversation.find(conversation_id)
    current_user = Person.find(current_user_id)
    if conversation.other_party(current_user).should_receive?("email_when_conversation_#{conversation.status}")
      PersonMailer.conversation_status_changed(conversation, host).deliver
    end
    if conversation.status.eql?("accepted")
      if conversation.listing.share_type.eql?(["give_away"]) && Time.now.month == 12
        conversation.offerer.give_badge("santa", host)
      end
      Delayed::Job.enqueue(TestimonialReminderJob.new(conversation.id, host), :priority => 0, :run_at => 1.week.from_now)
      EventFeedEvent.create(:person1_id => conversation.offerer.id, :person2_id => conversation.requester.id, :eventable_id => conversation.id, :eventable_type => "Conversation", :community_id => community_id, :category => "accept", :members_only => !conversation.listing.privacy.eql?("public"))
    end
  end
  
end