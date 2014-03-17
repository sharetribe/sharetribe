class ConversationAcceptedJob < Struct.new(:conversation_id, :current_user_id, :community_id) 
  
  include DelayedAirbrakeNotification
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end
  
  def perform
    community = Community.find(community_id)
    conversation = Conversation.find(conversation_id)
    current_user = Person.find(current_user_id)
    if conversation.other_party(current_user).should_receive?("email_when_conversation_#{conversation.status}")
      PersonMailer.conversation_status_changed(conversation, community).deliver
    end
    if conversation.status.eql?("accepted")
      if conversation.waiting_payment?(community)
        [3, 10].each do |send_interval|
          Delayed::Job.enqueue(PaymentReminderJob.new(conversation.id, conversation.payment.payer.id, community.id, 0), :priority => 0, :run_at => send_interval.days.from_now)
        end
      elsif community.testimonials_in_use
        [7, 21].each do |send_interval|
          Delayed::Job.enqueue(ConfirmReminderJob.new(conversation.id, conversation.requester.id, community_id, 0), :priority => 0, :run_at => send_interval.days.from_now)
        end
      end
    end
  end
  
end